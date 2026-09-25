require "nvchad.options"

-- Keep swap and undo files out of project directories.
local cache = vim.fn.stdpath "cache"

vim.opt.swapfile = true
vim.opt.directory = cache .. "/swap//"

vim.opt.backup = false

vim.opt.undofile = true
vim.opt.undodir = cache .. "/undo//"

for _, dir in ipairs { cache .. "/swap", cache .. "/undo" } do
  vim.fn.mkdir(dir, "p")
end
