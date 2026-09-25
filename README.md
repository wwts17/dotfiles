# dotfiles

个人 macOS 配置。Homebrew 安装软件，GNU Stow 将各工具目录中的配置链接到 `$HOME`。

```sh
bash scripts/install.sh   # 安装软件并链接配置
bash scripts/doctor.sh    # 检查环境
```

软件清单见 [Brewfile](Brewfile)。工具目录按 `$HOME` 下的目标路径组织，可单独应用：

```sh
stow -t "$HOME" zsh
```

Antigravity 的 `settings.json` 保留在本机；仓库中的 `settings.example.json` 仅供参考，Stow 不部署它。

修改配置与脚本时遵循 [项目规范](AGENTS.md)。
