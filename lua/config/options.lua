-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
--
--
--

local g = vim.g
local o = vim.o

g.autoformat = true
g.snacks_animate = true
g.ai_cmp = true
g.deprecation_warnings = false
g.lazyvim_prettier_needs_config = false

o.colorcolumn = "80"
