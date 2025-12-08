-- Set space as the leader key
vim.g.mapleader = " "

-- Basic Settings
vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.clipboard = "unnamedplus"

-- Keymaps 
vim.keymap.set("n", "<leader>w", ":w<CR>")
