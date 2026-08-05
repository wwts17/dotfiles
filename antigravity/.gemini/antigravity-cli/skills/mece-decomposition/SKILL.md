---
name: mece-decomposition
description: Deconstruct complex or ambiguous problems into Mutually Exclusive, Collectively Exhaustive sub-problems. Activate when facing unstructured requirements, multi-factor bugs, or architectural breakdowns.
---

# MECE Problem Decomposition

Apply the Mutually Exclusive, Collectively Exhaustive (MECE) framework to decompose complex or unstructured problems.

## Execution Framework

1. **Define the Top Boundary:** State the core problem in one precise sentence.
2. **First-Level Division (Mutually Exclusive):**
   - Divide the problem into 2–4 non-overlapping categories (e.g., Frontend vs Backend vs DB, or Runtime vs Configuration vs Infrastructure).
   - Ensure no sub-problem fits into multiple categories simultaneously.
3. **Completeness Audit (Collectively Exhaustive):**
   - Verify that all potential root causes or requirements fall strictly within the defined categories.
   - Add an explicit `Other / Edge Cases` bucket if necessary.
4. **Hierarchical Expansion:** Recursively break down each category until sub-issues reach single actionable steps.

## Deliverable Format

- **Root Problem Statement**
- **Decomposition Tree (MECE Breakdown)**
- **Priority Matrix (Impact vs Effort)**
