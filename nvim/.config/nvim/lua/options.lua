require "nvchad.options"

-- Keep all Neovim-generated temp files under ~/.cache/nvim/
-- so project dirs stay clean (no .swp / backup / undo files).
local cache = vim.fn.stdpath "cache"

-- Swap files (recover from unexpected crashes)
vim.opt.swapfile = true
vim.opt.directory = cache .. "/swap//"

-- Backup files
vim.opt.backup = false -- not needed, swap is enough

-- Persistent undo (u still works after closing nvim)
vim.opt.undofile = true
vim.opt.undodir = cache .. "/undo//"

-- Ensure dirs exist (shada is managed by NvChad, leave it alone)
for _, dir in ipairs { cache .. "/swap", cache .. "/undo" } do
  vim.fn.mkdir(dir, "p")
end
