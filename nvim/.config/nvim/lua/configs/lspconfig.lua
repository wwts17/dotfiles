require("nvchad.configs.lspconfig").defaults()

-- Batch-enable LSP servers via vim.lsp.enable().
-- Servers are installed by Mason; Neovim's built-in client launches them.
local servers = {
  "html",    -- vscode-html-language-server
  "cssls",   -- vscode-css-language-server
  "ts_ls",   -- TypeScript/JavaScript (typescript-language-server)
  "pyright", -- Python, best inference, from Microsoft
  "gopls",   -- Go, only official LSP
  "jsonls",  -- JSON, with JSON Schema validation
  "yamlls",  -- YAML, with K8s/Docker Compose schema completion
  "taplo",   -- TOML, only mature option
  "sqls",    -- SQL/MySQL, can run queries against a live DB
  "bashls",  -- Bash/Zsh/Sh, integrates shellcheck
  "marksman", -- Markdown, wiki-links + heading jumps + broken-link diagnostics
}

vim.lsp.enable(servers)

-- Java is handled separately by nvim-jdtls (see ftplugin/java.lua).
-- Don't enable here to avoid clashing with jdtls.
