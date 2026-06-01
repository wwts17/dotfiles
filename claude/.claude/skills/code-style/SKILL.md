---
name: code-style
description: 应用用户的代码风格偏好——清晰胜过聪明、少量重复胜过多余依赖、错误显式处理、出现三次才抽象、注释解释"为什么"、零值可用。写代码、评审或重构时使用。
---

# 代码风格

## 核心
代码一眼看懂;命名和结构承载含义,注释是最后手段,不是习惯。

## 适用场景
写、评审或重构任何代码时。

## 规则
- **清晰胜过聪明** ❌ `return (mask & flags) ^ (mask & ~flags)` ✅ `return flags != mask`
- **少量重复胜过多余依赖** ❌ 为一次 `groupBy()` 引入 `lodash` ✅ 内联写 5 行
- **错误是值,显式处理** ❌ `try { ... } catch {}`(吞掉) ✅ 向上传播,或 `catch (e: NotFoundError)` 并写明理由
- **出现三次前不抽象** ❌ 第二个相似 controller 就抽基类 ✅ 等第三次,看真正共享的
- **注释解释"为什么"** ❌ `i++  // i 自增` ✅ `// 上游在部署窗口返回 503,重试一次`
- **零值可用** ❌ `User` 必须先 `.init()` ✅ `var u User` 立即可用
- **需要注释才看懂就重写** ❌ 40 行函数靠 `// 步骤 1/2` 分段 ✅ 抽出 `validate()`/`transform()`

## 范例
❌ 吞掉错误,靠注释解释意图:
```go
func getUser(id string) *User {
    u, _ := db.Find(id) // 找不到就返回 nil
    return u
}
```
✅ 错误是值,显式处理;命名替代注释:
```go
func getUser(id string) (*User, error) {
    u, err := db.Find(id)
    if errors.Is(err, ErrNotFound) {
        return nil, nil // 不存在不算错误
    }
    return u, err
}
```
