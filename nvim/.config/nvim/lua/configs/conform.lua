return {
  formatters_by_ft = {
    lua         = { "stylua" },
    html        = { "prettier" },
    css         = { "prettier" },
    javascript  = { "prettier" },
    typescript  = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    python      = { "black" },
    go          = { "goimports" },
    json        = { "jq" },
    yaml        = { "prettier" },
    toml        = { "taplo" },
    sql         = { "sql_formatter" },
    java        = { "google_java_format" },
    sh          = { "shfmt" },
    bash        = { "shfmt" },
    zsh         = { "shfmt" },
    markdown    = { "prettier" },
  },

  formatters = {
    jq = {
      args = { "--indent", "2" },
    },
    shfmt = {
      args = { "-i", "2", "-ci" },
    },
  },
}
