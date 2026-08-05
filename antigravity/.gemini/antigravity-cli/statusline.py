#!/usr/bin/env python3
import sys
import os
import json
import subprocess
import time

SLIDING_CACHE_FILE = "/tmp/antigravity_statusline_sliding.json"

# ANSI Color sequences (Blue text)
BLUE = "\033[38;5;75m"  # Soft bright blue
RESET = "\033[0m"

def extract_workspace_path(ws):
    if not ws:
        ws = os.getcwd()
    if isinstance(ws, dict):
        ws = ws.get("current_dir") or ws.get("project_dir") or ws.get("path") or ws.get("uri") or os.getcwd()
    if not isinstance(ws, str):
        ws = str(ws)
    if ws.startswith("file://"):
        ws = ws[7:]
    return ws

def get_git_info(workspace_path):
    if not workspace_path or not os.path.exists(workspace_path):
        workspace_path = os.getcwd()
    try:
        branch_proc = subprocess.run(
            ['git', '-C', workspace_path, 'branch', '--show-current'],
            capture_output=True, text=True, timeout=1
        )
        branch = branch_proc.stdout.strip()
        if not branch:
            branch_proc = subprocess.run(
                ['git', '-C', workspace_path, 'rev-parse', '--short', 'HEAD'],
                capture_output=True, text=True, timeout=1
            )
            branch = branch_proc.stdout.strip()
        if not branch:
            return ""

        status_proc = subprocess.run(
            ['git', '-C', workspace_path, 'status', '--porcelain'],
            capture_output=True, text=True, timeout=1
        )
        is_clean = len(status_proc.stdout.strip()) == 0
        symbol = "[✓]" if is_clean else "[✗]"
        return f"{branch}{symbol}"
    except Exception:
        return ""

def format_tokens(num):
    try:
        num = float(num)
        if num >= 1_000_000:
            return f"{num / 1_000_000:.1f}M"
        elif num >= 1_000:
            return f"{num / 1_000:.1f}k"
        return str(int(num))
    except Exception:
        return "0"

def get_quota_str(quota_obj):
    if not isinstance(quota_obj, dict):
        return ""
    
    q5 = quota_obj.get("gemini-5h") or quota_obj.get("3p-5h") or {}
    q7 = quota_obj.get("gemini-weekly") or quota_obj.get("3p-weekly") or {}
    
    parts = []
    if q5:
        rem_frac = q5.get("remaining_fraction", 1.0)
        used_pct = int((1.0 - rem_frac) * 100)
        reset_s = int(q5.get("reset_in_seconds", 0))
        rh = reset_s // 3600
        rm = (reset_s % 3600) // 60
        parts.append(f"5h:{used_pct}%({rh}h{rm}m)")
        
    if q7:
        rem_frac = q7.get("remaining_fraction", 1.0)
        used_pct = int((1.0 - rem_frac) * 100)
        reset_s = int(q7.get("reset_in_seconds", 0))
        rd = reset_s // 86400
        rh = (reset_s % 86400) // 3600
        parts.append(f"7d:{used_pct}%({rd}d{rh}h)")
        
    return " ".join(parts)

def update_sliding_tokens(session_id, session_tokens):
    now = time.time()
    data = {"history": []}

    if os.path.exists(SLIDING_CACHE_FILE):
        try:
            with open(SLIDING_CACHE_FILE, 'r') as f:
                data = json.load(f)
        except Exception:
            data = {"history": []}

    cutoff_24h = now - 86400
    cutoff_60s = now - 60

    history = [e for e in data.get("history", []) if isinstance(e, dict) and e.get("timestamp", 0) > cutoff_24h]
    
    history.append({
        "timestamp": now,
        "session_id": str(session_id),
        "tokens": session_tokens
    })

    try:
        with open(SLIDING_CACHE_FILE, 'w') as f:
            json.dump({"history": history}, f)
    except Exception:
        pass

    tokens_60s = sum(e.get("tokens", 0) for e in history if e.get("timestamp", 0) > cutoff_60s)
    tokens_24h = sum(e.get("tokens", 0) for e in history)

    return tokens_60s, tokens_24h

def extract_default_info(input_data):
    model_obj = input_data.get("model", {})
    if isinstance(model_obj, str):
        model_name = model_obj
        effort = ""
    elif isinstance(model_obj, dict):
        model_name = model_obj.get("display_name") or model_obj.get("id") or ""
        effort = model_obj.get("effort") or model_obj.get("thinking_level") or ""
    else:
        model_name = ""
        effort = ""

    if not effort:
        effort = input_data.get("effort") or input_data.get("thinking_level") or ""

    mode = input_data.get("mode") or input_data.get("plan_mode") or ""

    parts = []
    if mode:
        parts.append(str(mode))
    if model_name:
        parts.append(str(model_name))
    
    # Deduplicate effort if it's already contained in model_name (e.g., "Gemini 3.6 Flash (High)")
    if effort and effort.lower() not in model_name.lower():
        parts.append(str(effort))

    if parts:
        return " · ".join(parts)
    return ""

def main():
    try:
        input_data = {}
        if not sys.stdin.isatty():
            raw_in = sys.stdin.read()
            if raw_in:
                try:
                    input_data = json.loads(raw_in)
                except Exception:
                    input_data = {}

        raw_ws = input_data.get("workspace")
        workspace_path = extract_workspace_path(raw_ws)
        ws_name = os.path.basename(workspace_path.rstrip('/')) if workspace_path else "Workspace"
        session_id = input_data.get("session_id", "default_session")

        ctx_obj = input_data.get("context_window", {})
        if isinstance(ctx_obj, dict) and "used_percentage" in ctx_obj:
            ctx_pct = float(ctx_obj.get("used_percentage", 0.0))
            cur_usage = ctx_obj.get("current_usage", {})
            cache_read = cur_usage.get("cache_read_input_tokens", 0)
            input_tok = cur_usage.get("input_tokens", 0)
            total_input = cache_read + input_tok
            session_tokens = ctx_obj.get("total_input_tokens", 0) + ctx_obj.get("total_output_tokens", 0)
        else:
            tokens_obj = input_data.get("tokens", {})
            if not isinstance(tokens_obj, dict):
                tokens_obj = {}
            cache_read = tokens_obj.get("cacheReadInputTokens", 0)
            input_tok = tokens_obj.get("input", 0)
            total_input = cache_read + input_tok
            output_tok = tokens_obj.get("output", 0)
            session_tokens = total_input + output_tok
            max_context = 1048576
            ctx_pct = (total_input / max_context) * 100 if max_context else 0.0

        step_count = input_data.get("step_count", input_data.get("turn_index", 0))
        try:
            step_count = int(step_count)
        except Exception:
            step_count = 0

        duration_ms = input_data.get("duration_ms", input_data.get("latency", 0))
        try:
            duration_s = float(duration_ms) / 1000.0 if duration_ms else 0.0
        except Exception:
            duration_s = 0.0

        # Quota from official payload
        official_quota_str = get_quota_str(input_data.get("quota"))

        tpm, total_24h = update_sliding_tokens(session_id, session_tokens)
        
        if official_quota_str:
            quota_data = input_data.get("quota", {})
            q5 = quota_data.get("gemini-5h") or quota_data.get("3p-5h") or {}
            rem_f = float(q5.get("remaining_fraction", 1.0))
            if rem_f > 0.5:
                lamp = "🟢"
            elif rem_f > 0.2:
                lamp = "🟡"
            else:
                lamp = "🔴"
            rate_group = f"{lamp}{official_quota_str}"
        else:
            if tpm < 300_000:
                lamp = "🟢"
            elif tpm < 800_000:
                lamp = "🟡"
            else:
                lamp = "🔴"
            rate_group = f"{lamp}{format_tokens(tpm)}/m(24h:{format_tokens(total_24h)})"

        cache_pct = (cache_read / total_input) * 100 if total_input > 0 else 0.0
        cache_str = f"Cache:{cache_pct:.0f}%" if cache_pct > 0 else "Cache:0%"
        ctx_group = f"Ctx:{ctx_pct:.1f}%({cache_str})"

        sess_parts = [f"Sess:{format_tokens(session_tokens)}"]
        sub_parts = []
        if step_count > 0:
            sub_parts.append(f"#{step_count}")
        if duration_s > 0:
            sub_parts.append(f"{duration_s:.1f}s")

        if sub_parts:
            sess_group = f"{sess_parts[0]}({' '.join(sub_parts)})"
        else:
            sess_group = sess_parts[0]

        git_info = get_git_info(workspace_path)

        default_info = extract_default_info(input_data)

        parts = [ws_name, rate_group, ctx_group, sess_group, git_info]
        left_str = "  ".join(p for p in parts if p)

        if default_info:
            full_out = f"{left_str}  ·  {default_info}"
        else:
            full_out = left_str

        # Colorize full output text in blue ANSI escape code
        colored_out = f"{BLUE}{full_out}{RESET}"
        print(colored_out)
    except Exception as e:
        ws_name = os.path.basename(os.getcwd())
        print(f"{BLUE}{ws_name}  🟢0/m  Ctx:0.0%  Sess:0{RESET}")

if __name__ == "__main__":
    main()
