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

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "java", "typescript", "javascript", "tsx",
        "python", "html", "css", "json",
        "go", "sql", "toml", "yaml",
        "bash",
        "http", "graphql",
        "markdown", "markdown_inline",
      },
    },
  },

  -- mason-tool-installer installs the tools listed below; Mason alone does not.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    lazy = false,
    opts = {
      run_on_start = true,
      ensure_installed = {
        -- LSP servers (Mason package names)
        "html-lsp",
        "css-lsp",
        "typescript-language-server",
        "pyright",
        "gopls",
        "json-lsp",
        "yaml-language-server",
        "taplo",
        "sqls",
        "jdtls",
        "bash-language-server",
        "marksman",
        -- Formatters
        "prettier",
        "black",
        "goimports",
        "jq",
        "sql-formatter",
        "google-java-format",
        "shfmt",
      },
    },
  },

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

  -- Java setup lives in ftplugin/java.lua.
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
  },

  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      default_view = "body",
      default_env = "dev",
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

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      render_modes = { "n", "c" },
      heading = { sign = false },
      code = { width = "block", right_pad = 2 },
    },
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", ft = "markdown", desc = "Toggle md render" },
    },
  },

  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    -- Download the binary without Node/Yarn or a loaded plugin runtimepath.
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
