# macOS 上的 Nix、Homebrew 与自建 dotfiles 管理器

调研日期：2026-09-26。范围：官方文档与本仓库配置；没有安装 Nix、修改 shell 或迁移文件。以下“建议”属于基于资料和当前仓库的判断。

## 结论

建议先验证 **Home Manager + nix-darwin + Homebrew** 的组合，不立即开发通用管理器，也不把“使用 Nix 声明”与“移除 Homebrew”绑定。nix-darwin 已经提供 Homebrew 安装声明；Home Manager 已覆盖用户文件、环境变量、PATH 和大量应用的 shell 集成。目标能力存在显著重合。[nix-darwin Homebrew 选项](https://nix-darwin.github.io/nix-darwin/manual/)、[Home Manager 用户环境](https://nix-community.github.io/home-manager/options/home-manager/home.html)

自建工具若保留价值，主要是：更简单的学习模型、对已有安装的接管、以软件为单位解释 PATH/变量来源，以及针对个人流程的交互体验。它不自然获得 Nix 的构建隔离和依赖锁定保障。只有试用证明这些体验缺口重要，才值得承担长期维护成本。

## 实际比较对象

| 组件 | 职责 |
|---|---|
| Nix / Nixpkgs | 包构建、存储与包集合 |
| Home Manager | 用户软件、dotfiles、环境和应用模块 |
| nix-darwin | macOS 系统配置与集成，包括 Homebrew |
| Homebrew Bundle | 用 Brewfile 声明安装清单 |

Home Manager 可作为 nix-darwin 模块，一次 `darwin-rebuild switch` 同时应用系统和用户配置；不是必须维持两个独立的日常入口。[Home Manager 的 nix-darwin 集成](https://nix-community.github.io/home-manager/installation/nix-darwin.html)

## 已经覆盖的需求

- 用户软件用 `home.packages`；原生文件可通过 `home.file` 的 `source` 或 `text` 管理；`home.sessionVariables`、`home.sessionPath` 声明环境；复杂行为可用激活脚本。文件冲突检测与副作用执行顺序已有机制。[Home Manager 用户环境](https://nix-community.github.io/home-manager/options/home-manager/home.html)
- Zsh 模块有补全、Antidote、插件、环境和初始化扩展入口。Starship 与 Zoxide 有专用配置和 Zsh 集成选项。因此当前 `.zshrc` 中相当部分胶水代码已有模块替代。[Zsh](https://nix-community.github.io/home-manager/options/home-manager/programs/zsh.html)、[Starship](https://nix-community.github.io/home-manager/options/home-manager/programs/starship.html)、[Zoxide](https://nix-community.github.io/home-manager/options/home-manager/programs/zoxide.html)
- nix-darwin 的 `homebrew.brews`、`homebrew.casks` 等生成 Brewfile，在激活时调用 Homebrew Bundle。意味着“统一声明，安装后端仍是 brew”并非新能力。[nix-darwin 手册](https://nix-darwin.github.io/nix-darwin/manual/)
- Homebrew Bundle 本身已经是声明式入口，并覆盖 Cask、Mac App Store、若干语言包管理器等；新工具的差异不能仅是另一份安装清单。[Homebrew Bundle](https://docs.brew.sh/Brew-Bundle-and-Brewfile)

## macOS 应用与 Homebrew

不要说“Nix 不支持 GUI”。正确的评估单位是具体软件、架构、所需系统集成和配置模块。Nixpkgs 的总包数不等于可用的 macOS 包数。此调研没有对每个软件执行 Darwin 构建，因此不宣称整个 Brewfile 能直接迁移。

Homebrew Cask 对 `.app`、`.pkg` 等 macOS 分发形式有专门安装规则；虚拟化、后台组件、自动更新等应用应逐项评估，不能按普通 CLI 二进制处理。[Cask Cookbook](https://docs.brew.sh/Cask-Cookbook)

本仓库 Brewfile 包含 OrbStack、Ghostty、cmux、Rectangle 四个 Cask。建议第一阶段继续由 Homebrew 安装，让 nix-darwin 统一声明它们。这样能先检验统一管理体验，不必同时承担 GUI 安装路线迁移。

## 成本与可复现边界

Nix 在 macOS 的安装不是单个用户目录中的可执行文件：官方安装器创建构建用户和守护服务；现代 macOS 上还建立 APFS store 卷，配置 synthetic.conf、fstab 与启动挂载服务。这些工作由安装器自动完成，但构成额外运维面。官方手册还记录过 macOS 升级后的构建用户修复案例。[Nix 安装手册](https://nix.dev/manual/nix/stable/installation/installing-binary)

nix-darwin 支持 Intel 与 Apple Silicon；其 README 当前推荐新手使用 flakes，同时明确 flakes 仍是实验功能，并说明官方 Nix 安装器没有自动卸载程序，推荐具备卸载能力的 Lix 安装器。安装路线需按当前文档选择，不能假定所有 Nix 发行版和安装器完全等价。[nix-darwin README](https://github.com/nix-darwin/nix-darwin)

锁定 flake 输入使 Nix 配置及包定义的来源固定；这不等于冻结 macOS、应用数据、外部下载服务和所有命令副作用。[Nix flake 手册](https://nix.dev/manual/nix/stable/command-ref/new-cli/nix3-flake)

Homebrew 管理的部分也不会因为外面包了 Nix 声明就变为 Nix store 中的受锁定产物。Bundle 在包过时的情况下可以升级；nix-darwin 可控制激活时的更新和清理行为，但旧 Nix generation 不是旧 Cask 二进制和应用数据库的完整快照。因此不应承诺一键还原整台 Mac。[Homebrew Bundle](https://docs.brew.sh/Brew-Bundle-and-Brewfile)、[nix-darwin 手册](https://nix-darwin.github.io/nix-darwin/manual/)

初次迁移保留 `homebrew.onActivation.cleanup = "none"`。默认行为会保留未声明的软件；`uninstall` 和 `zap` 有删除行为，后者还清除 Cask 关联文件，不适合探索阶段自动启用。[nix-darwin 手册](https://nix-darwin.github.io/nix-darwin/manual/)

## 针对本仓库的验证方案

仓库当前用 Stow 管理文件，Brewfile 管理安装，Zsh 负责补全、初始化与路径；还存在 fnm、Pixi、Go 自动工具链和 SDKMAN 等动态环境管理。它们的动态状态不会因为迁移 dotfiles 自动进入 Nix 锁定范围。这是仓库观察与边界判断。

建议先做可审阅、可撤回的小范围试用：

1. 选择 Zsh、Starship、Zoxide 作为样本，将现有行为映射到 Home Manager，保留复杂初始化入口。
2. 保持原生 Starship/Ghostty 等文件，不要求为了统一而全改写为 Nix 属性。
3. 将四个 Cask 保留在 Homebrew；需要统一入口时再接入 nix-darwin。
4. 每个受管理文件一次只交给 Stow 或 Home Manager 中的一方；先构建和查看生成结果，再激活。
5. 验证 PATH 顺序、补全、fnm 目录切换、SDKMAN、OrbStack 命令可见性以及本地覆盖。
6. 用“添加一个工具、修改变量、回退配置、查明 PATH 来源”四类日常任务判断体验。

若现有模块已覆盖需求，继续采用 Nix 生态；若唯一问题是命令较长，增加薄 CLI 包装即可。只有确认“不愿承担 Nix 安装/语言复杂度，同时仍需要工具级声明、接管和解释能力”时，再开发基于 Homebrew 的轻量编排层。那是有明确能力边界的产品选择，而不是更少代码却提供全部 Nix 保障的替代品。
