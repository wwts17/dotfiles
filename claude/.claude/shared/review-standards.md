# Review standards

What a review judges and how a finding is written. Shared by every reviewer agent; the
agent file that points here adds how that agent is called and what it does with the
result. This file is not a skill and does not fire on its own.

## Verdicts

- **Pass**: meets the standards, no blocking defects, deliverable as-is.
- **Needs improvement**: works, but has non-blocking gaps in readability, convention, or edge cases.
- **Reject**: a blocking defect — logic error, misleading claim, instruction that cannot be run, or result that cannot be verified.

## Finding format

Every finding is these five lines and nothing else:

```
Severity: Reject | Needs improvement | Pre-existing
Introduced: yes | copied | untouched
Outcome: one sentence, at most 25 words
Fix: one sentence, at most 25 words
Where: file:line
```

- **Introduced**: `yes` when this change wrote the defect. `copied` when this change
  reproduced a pattern that already existed elsewhere. `untouched` when this round did
  not change the code at all. Anything other than `yes` is Severity `Pre-existing`.
- **Outcome**: what an observer sees — who hits what, in which situation. Naming a class,
  a variable, or a derivation ("the path comes from X") is a mechanism, not an outcome,
  and does not belong on this line. Put the mechanism in Notes.
- **Fix**: name the cost — how many lines, and whether a new test is needed.
- **Pre-existing**: the change neither introduced it nor made it worse. Pre-existing is
  never a Reject.

Every finding then shows the code, at every severity. Two fenced blocks follow the five
lines:

```
Now:
<the cited lines, copied verbatim from the file, each with its line number>

After:
<the same lines rewritten — the change itself, not a description of it>
```

- Copy `Now` out of the file. Never retype it from memory and never tidy it up: a quote
  that does not match the file is a wrong finding.
- `After` is real code the reader could paste. When the fix is a deletion, write
  `After: (deleted)`. When the fix is a new file or a new test, drop `Now` and let
  `After` carry the new code.
- Each block is at most 12 lines and a finding cites at most 3 locations. When the change
  is larger, show the lines the finding turns on and say in Notes what was left out.

Reasoning, reproduction steps, mechanism, and any argument against another tool's
conclusion go in a Notes block after the finding. None of them appear on the five lines
or in the two blocks.

- No limit on Reject findings. At most 3 Needs improvement findings; past that, write
  "plus N similar items". A Notes block is at most 5 lines.
- Run an experiment only to confirm a Reject-level finding. A Needs improvement finding
  quotes the code and proposes the change like any other, but goes no further than that.

## Standards

- Code: read the `coding` skill (`skills/coding/SKILL.md` under your configuration directory) and apply it, calibration examples included.
- Commits: read the `git-commits` skill (`skills/git-commits/SKILL.md`) and apply it.
- Documents and plans: read the `tech-doc` skill (`skills/tech-doc/SKILL.md`) and apply it; for a plan, also check it against that skill's Change plans section.
- Assistant configuration (the global instructions file, skills, agents): a description states when to use the unit without listing its body rules; no content duplicated across files; no references to files that don't exist.

## Review dimensions

Each item below is a question you must answer, not an answer you must give. Answer every
one and cite the evidence (file:line, or the specific input), unless the agent file that
pointed you here narrows the set. Where your judgement conflicts with a default rule
elsewhere, say why and follow your judgement.

- **Internal consistency**: does the function's precondition hold at every call site? Is the state left behind on the failure path consistent with the success path?
- **Boundaries and failures**: empty input, a single element, the maximum value, concurrent access, a failing downstream with retries — walk each one. Which is uncovered, and why is that acceptable?
- **Problems introduced**: has every call site the change touches been read? Does anything depend on the behavior that changed?
- **Necessary implementation**: which part of this implementation is not needed by the current requirement? Does it still satisfy the requirement with that part removed?
- **A better implementation**: is there one with less state, fewer branches, or fewer layers of indirection? If you can name a specific alternative, write it down and say why it is better or worse. If you cannot, "none found" is a complete answer.
- **Comments**: label every comment the diff adds a, b, or c per the coding skill's Comments section. Any that fits none is Needs improvement.
- **Merge readiness**: tests pass, no TODOs or debugging leftovers, failure paths handled, rollback path clear. Any one missing blocks the merge. This is separate from the quality verdict — "good enough" is not "safe to merge".

## Output format

The caller decides where this verdict is shown; it must not drop or reword a finding.

### Verdict
- Overall: [Pass / Needs improvement / Reject]
- Conclusion: [one sentence — deliver or not, and why]
- Rejects: [N]

### Findings
Grouped by dimension, each one in the five-line Finding format with its `Now` and
`After` blocks, and its Notes block underneath when there is something to add. Write
"none" for a dimension with no finding.
