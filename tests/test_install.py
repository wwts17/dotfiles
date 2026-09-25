import os
import json
import subprocess
import tempfile
import unittest
from pathlib import Path


INSTALL = Path(__file__).resolve().parents[1] / "scripts/install.sh"


class InstallResultTest(unittest.TestCase):
    def run_install(self, stow_status=0, fnm_status=0, existing_settings=None):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory) / "home"
            bin_dir = Path(directory) / "bin"
            (home / ".sdkman/bin").mkdir(parents=True)
            (home / ".sdkman/bin/sdkman-init.sh").write_text("# installed\n")
            (home / ".gitconfig.local").write_text("[user]\n")
            if existing_settings is not None:
                settings_file = home / ".gemini/antigravity-cli/settings.json"
                settings_file.parent.mkdir(parents=True)
                settings_file.write_text(json.dumps(existing_settings))
            bin_dir.mkdir()
            for name, body in {
                "uname": "echo Darwin",
                "brew": "exit 0",
                "stow": f"exit {stow_status}",
                "fnm": f"exit {fnm_status}",
                "jq": "python3 - \"$@\" <<'PY'\nimport json, sys\ndata = json.load(open(sys.argv[-1]))\ndata['statusLine'] = {'type': 'command', 'command': sys.argv[3], 'enabled': True}\njson.dump(data, sys.stdout)\nPY",
            }.items():
                command = bin_dir / name
                command.write_text("#!/bin/sh\n" + body + "\n")
                command.chmod(0o755)

            env = dict(os.environ, HOME=str(home), PATH=f"{bin_dir}:/usr/bin:/bin")
            result = subprocess.run(["/bin/bash", str(INSTALL)], env=env, capture_output=True, text=True)
            settings = home / ".gemini/antigravity-cli/settings.json"
            return result, json.loads(settings.read_text()) if settings.exists() else None

    def test_stow_failure_stops_install(self):
        result, settings = self.run_install(stow_status=1)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("completed successfully", result.stdout)
        self.assertIsNone(settings)

    def test_fnm_failure_stops_install(self):
        result, _ = self.run_install(fnm_status=1)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("completed successfully", result.stdout)

    def test_success_requires_all_steps(self):
        result, settings = self.run_install()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("completed successfully", result.stdout)
        self.assertTrue(settings["statusLine"]["enabled"])

    def test_existing_antigravity_settings_are_preserved(self):
        original = {"model": "local choice"}
        result, settings = self.run_install(existing_settings=original)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(settings, original)


if __name__ == "__main__":
    unittest.main()
