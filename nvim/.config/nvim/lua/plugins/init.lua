return {
  {
    "stevearc/conform.nvim",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- Treesitter: syntax/fold/indent baseline for all target languages
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "java", "typescript", "javascript", "tsx",
        "python", "html", "css", "json",
        "go", "sql", "toml", "yaml",
        "bash",    -- bash parser covers zsh/sh
        "http", "graphql", -- needed by kulala.nvim
        "markdown", "markdown_inline", -- block + inline parsers (both needed)
      },
    },
  },

  -- Mason: auto-install missing LSP servers and formatters at startup
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        -- LSP servers
        "typescript-language-server", -- ts_ls
        "pyright",                    -- python
        "gopls",                      -- go
        "json-lsp",                   -- jsonls
        "yaml-language-server",       -- yamlls
        "taplo",                      -- toml
        "sqls",                       -- sql/mysql
        "jdtls",                      -- java
        "bash-language-server",       -- zsh/bash/sh
        "marksman",                   -- markdown
        -- Formatters / tools
        "prettier",
        "black",
        "goimports",
        "jq",
        "sql-formatter",
        "google-java-format",
        "shfmt",
      })
    end,
  },

  -- Lazygit: open in a floating window with <leader>gg, no terminal switch
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },

  -- Java LSP: nvim-jdtls is the de facto wrapper for jdtls
  -- (workspace + lifecycle handling). Config lives in lua/ftplugin/java.lua,
  -- auto-triggered when opening a .java file.
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
  },

  -- Kulala: HTTP client, send requests directly from .http/.rest files
  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      default_view = "body",      -- response window shows body by default
      default_env = "dev",        -- default env-vars file key
      debug = false,
    },
    keys = {
      { "<leader>Rs", function() require("kulala").run() end,            ft = { "http", "rest" }, desc = "Send request" },
      { "<leader>Ra", function() require("kulala").run_all() end,        ft = { "http", "rest" }, desc = "Send all requests" },
      { "<leader>Rn", function() require("kulala").jump_next() end,      ft = { "http", "rest" }, desc = "Next request" },
      { "<leader>Rp", function() require("kulala").jump_prev() end,      ft = { "http", "rest" }, desc = "Prev request" },
      { "<leader>Rb", function() require("kulala").set_selected_env() end, ft = { "http", "rest" }, desc = "Switch env" },
      { "<leader>Rc", function() require("kulala").copy() end,           ft = { "http", "rest" }, desc = "Copy as curl" },
      { "<leader>Ri", function() require("kulala").inspect() end,        ft = { "http", "rest" }, desc = "Inspect request" },
      { "<leader>Rq", function() require("kulala").close() end,          ft = { "http", "rest" }, desc = "Close response" },
    },
  },

  -- render-markdown: in-buffer rendering of headings/lists/code/tables.
  -- Renders in normal mode, drops back to raw text in insert mode for editing.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      render_modes = { "n", "c" }, -- render in normal+command, raw in insert/visual
      heading = { sign = false },  -- no signcolumn icons, cleaner gutter
      code = { width = "block", right_pad = 2 },
    },
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", ft = "markdown", desc = "Toggle md render" },
    },
  },

  -- markdown-preview: opens browser tab with live-rendered markdown.
  -- For final polish / sharing / mermaid + math.
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    -- Use the upstream install.sh — it downloads the prebuilt binary directly
    -- and works without node/yarn. Avoids the ft-lazy runtimepath problem
    -- that breaks `vim.fn["mkdp#util#install"]()`.
    build = "cd app && ./install.sh",
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Toggle browser preview" },
    },
    config = function()
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_theme = "dark"
    end,
  },
}
