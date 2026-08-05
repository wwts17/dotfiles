---
name: quality-review
description: Audit deliverables before final output against correctness, minimal edits, and simplicity criteria. Activate prior to presenting major code changes, technical plans, or artifacts.
---

# Pre-Delivery Quality Audit

Execute a rigorous self-audit to verify solution correctness, scope control, and documentation integrity.

## Audit Checklist

- [ ] **Empirical Verification:** Have all changes been verified via clean build outputs, passing tests, or verified logs?
- [ ] **No Guessing / Speculation:** Are all API parameters, schemas, and paths verified against source code?
- [ ] **Minimal Interventions:** Are edits strictly limited to requested changes without unsolicited refactoring?
- [ ] **Preserved Contracts:** Are all existing public signatures and unrelated docstrings intact?
- [ ] **Clean Code & Simplicity:** Is the implementation the simplest viable solution without speculative abstractions?

## Deliverable Format

- **Audit Summary (Pass/Fail)**
- **Verification Command Outputs**
- **Risks & Open Questions**
