---
name: coding
description: The engineering principles this repo's code follows, with worked ❌/✅ examples. Use when implementing, reviewing, or refactoring code.
---

# Coding

## When to use

Implementing, reviewing, or refactoring code.

The three Silent failures in `~/.claude/CLAUDE.md` are always in effect and are not
repeated here. Everything below is a default, not a prohibition: deviate when you have
a reason, and say what the reason is.

## Principles

- Clear is better than clever. Readability comes first — no cryptic one-liners, no hidden magic.
- Data dominates. Define the data structures and their lifecycle before the logic; when the data is right, the code follows.
- Decide who owns each piece of mutable state. When several execution flows touch it, don't communicate by sharing memory — share memory by communicating: hand ownership through a queue or channel instead of guarding shared state with locks.
- Keep it simple. Pick the simplest design that works, and cut every field, parameter, and layer the current requirement doesn't need.
- Don't pick a complex algorithm without profile data. Fancy algorithms are buggier, have big constants, and n is usually small.
- Measure. Don't tune for speed until you've measured, and even then don't unless one part of the code overwhelms the rest.
- The bigger the interface, the weaker the abstraction. An interface is defined by its consumer and stays small.
- One function does one thing. A flag parameter that switches behavior means it should be two functions.
- A little copying is better than a little dependency.
- Don't abstract until the third occurrence.
- Make the zero value useful — a value should be usable without an init call.
- Read the relevant code before editing; reuse what exists; make the smallest change that works.
- Test first, by default. In a module that has test infrastructure, write the failing test before the change: no behavior change without a failing test, no bug fix without a reproducing test. In a module that has none, say so, say why, and give manual verification steps instead. Never weaken an assertion or delete a test to make it pass, and refactor only while the tests are green.

## Comments

- Default to no comment. Code explains itself through naming and structure.
- A comment is allowed only in these three cases, and must fall into one of them:
  a. A non-obvious constraint from outside the code — an upstream quirk, a protocol
     requirement, a workaround with an issue link.
  b. A deliberate deviation from the obvious implementation, with the reason.
  c. An invariant a future editor could break that the tests would not catch.
- Never: restating what the code does, at any level ("loop over users", "handle the
  error"); a doc comment on a private function, or on one whose name and signature
  already say it; section banners (`// ---- helpers ----`); adjectives and adverbs
  (carefully, simply, robust, gracefully, properly, efficiently, and their Chinese
  equivalents).
- Form: one sentence, at most 15 words (30 characters in Chinese), spoken plainly.
  Needing a second sentence means the code should be restructured instead.
- Language: follow the comments already in the file; in a new file write them in Chinese.
  Write Chinese comments as natural spoken sentences, not translationese such as
  "对……进行……" or "……的处理".
- Check before delivery: count the comments in the diff, label each one a, b, or c, and
  delete the ones that fit none.

❌ `// Carefully validate the input before processing to ensure robustness` ✅ no comment — the name `validateInput` already says it
❌ `// Retry the request` ✅ `// upstream returns 503 during deploy windows, retry once` (case a)
❌ `// 对用户列表进行遍历处理` ✅ no comment

## Calibration examples

These are anchors showing what the judgement looks like in a concrete case. They are not
an exhaustive list, and a case that resembles none of them is not thereby fine.

- Clear is better than clever. ❌ `return (flags ^ mask) != 0` ✅ `return flags != mask`
- Small interfaces. ❌ one 20-method `Service` interface ✅ a 1–2 method interface at the call site
- One function does one thing. ❌ `render(data, isPreview)` ✅ `render(data)` and `renderPreview(data)`
- Errors are values. ❌ `try { ... } catch {}` ✅ propagate, or catch the specific error with a stated reason
- A little copying. ❌ adding lodash for one `groupBy` ✅ five inline lines
- Useful zero value. ❌ `User` unusable before `.init()` ✅ `var u User` works immediately
- Rule of three. ❌ a base class at the second similar controller ✅ wait for the third, extract what is truly shared

❌ Swallowed error, and a comment doing the naming's job:
```go
func getUser(id string) *User {
    u, _ := db.Find(id) // returns nil if missing
    return u
}
```
✅ Error handled as a value, names carry the meaning:
```go
func getUser(id string) (*User, error) {
    u, err := db.Find(id)
    if errors.Is(err, ErrNotFound) {
        return nil, nil // absence is not an error here
    }
    return u, err
}
```
