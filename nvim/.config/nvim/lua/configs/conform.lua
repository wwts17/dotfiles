return {
  formatters_by_ft = {
    lua         = { "stylua" },
    html        = { "prettier" },
    css         = { "prettier" },
    javascript  = { "prettier" },
    typescript  = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    python      = { "black" },          -- zero-config, de facto Python formatter
    go          = { "goimports" },      -- gofmt + auto-organize imports
    json        = { "jq" },             -- cleanest JSON output
    yaml        = { "prettier" },
    toml        = { "taplo" },          -- only mature TOML formatter
    sql         = { "sql_formatter" },  -- supports MySQL dialect
    java        = { "google_java_format" },
    sh          = { "shfmt" },
    bash        = { "shfmt" },
    zsh         = { "shfmt" },          -- shfmt supports zsh/bash/posix sh
    markdown    = { "prettier" },
  },

  -- Format on save (disabled by default; uncomment to enable)
  -- format_on_save = {
  --   timeout_ms = 800,
  --   lsp_fallback = true,
  -- },

  -- jq: 2-space indent, preserve key order
  formatters = {
    jq = {
      args = { "--indent", "2" },
    },
    shfmt = {
      args = { "-i", "2", "-ci" }, -- 2-space indent, case statements indented
    },
  },
}
