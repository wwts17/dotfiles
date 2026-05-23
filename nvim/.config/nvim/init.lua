vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- Load base46 theme cache. After a wipe, NvChad regenerates it on first :Lazy sync,
-- so swallow the load error on fresh checkout instead of erroring on every startup.
for _, name in ipairs { "defaults", "statusline" } do
  pcall(dofile, vim.g.base46_cache .. name)
end

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)
