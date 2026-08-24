---
paths:
  - "**/*.{go,py,ts,tsx,js,jsx,mjs,java,kt,rs,c,cc,cpp,h,hpp,rb,swift,sh,zsh,sql,vue,scala}"
---

# Coding Rules

Apply when implementing, reviewing, or refactoring code.

## Data first

1. Define the data structures and their lifecycle before writing logic; when the data is right, the code follows.
2. Decide who owns each piece of mutable state. When multiple execution flows touch it, don't communicate by sharing memory — share memory by communicating: hand ownership through a queue, channel, or message instead of guarding shared state with locks.
3. Start with the most direct implementation. Optimize later, and only with measurements (see the performance skill).
4. Cut every field, parameter, and layer the current requirement doesn't need.

## Test discipline

- Write the failing test before changing behavior.
- Reproduce a bug in a test before fixing it.
- Never weaken assertions or delete tests to make them pass; if a test is wrong, fix it deliberately and say so.
- Refactor only when tests are green, and keep them green.

## Style rules

- Clear is better than clever. ❌ `return (flags ^ mask) != 0` ✅ `return flags != mask`
- The bigger the interface, the weaker the abstraction. Interfaces are defined by the consumer and stay small. ❌ one 20-method `Service` interface ✅ a 1–2 method interface at the call site
- One function does one thing. ❌ `render(data, isPreview)` — a flag switching behavior ✅ `render(data)` and `renderPreview(data)`
- Errors are values; handle them explicitly. ❌ `try { ... } catch {}` ✅ propagate, or catch the specific error with a stated reason
- A little copying is better than a little dependency. ❌ adding lodash for one `groupBy` ✅ five inline lines
- Make the zero value useful. ❌ `User` unusable before `.init()` ✅ `var u User` works immediately
- Don't abstract until the third occurrence. ❌ a base class at the second similar controller ✅ wait for the third, extract what's truly shared
- Comments explain why, not what. ❌ `i++ // increment i` ✅ `// upstream returns 503 during deploy windows, retry once`

## Example

❌ Swallowed error, a comment doing the naming's job:
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
