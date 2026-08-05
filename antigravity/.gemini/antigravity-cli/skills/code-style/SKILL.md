---
name: code-style
description: Apply software craftsmanship, minimal mutation, and clean code guidelines. Activate when writing, reviewing, or refactoring code.
---

# Code Style & Craftsmanship Guidelines

Write clean, readable, and defensive code that aligns with modern software engineering standards.

## Engineering Standards

1. **Explicit Naming:** Use intention-revealing, domain-accurate names for variables, functions, and classes.
2. **Defensive Dereferencing:** Always verify object initialization and non-null states before dereferencing properties to prevent NPE or AttributeError crashes.
3. **Immutability & Pure Functions:** Prefer local state mutation over mutating global state or private third-party DOM properties.
4. **No Snippet Tunnel Vision:** Inspect complete data structure definitions before writing code that consumes them.
5. **Preserve Comments:** Retain all pre-existing docstrings and comments unrelated to code modifications.
