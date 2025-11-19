vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = false

local opt = vim.opt

opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.expandtab = true
opt.laststatus = 0

opt.colorcolumn = "80"
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.inccommand = "split"
opt.cursorline = true
opt.scrolloff = 10
opt.confirm = true
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.showmode = false

vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)
