# Git Safety Boundaries

1. **Manual Push Only:** Never execute `git push`. All push operations must be performed manually by the user.
2. **No Wildcard Deletions:** Commands such as `rm *` or `rm -rf *` are prohibited. Always specify explicit file targets.
3. **Verify Git Working Tree:** Always check `git status` or `git branch` before making major file modifications.
