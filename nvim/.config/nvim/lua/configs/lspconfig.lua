require("nvchad.configs.lspconfig").defaults()

local servers = {
  "html",
  "cssls",
  "ts_ls",
  "pyright",
  "gopls",
  "jsonls",
  "yamlls",
  "taplo",
  "sqls",
  "bashls",
  "marksman",
}

vim.lsp.enable(servers)

-- Java is configured separately in ftplugin/java.lua to avoid duplicate clients.
