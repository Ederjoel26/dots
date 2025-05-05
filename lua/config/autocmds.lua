-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--

local cmd = vim.api.nvim_create_autocmd

cmd("FileType", {
  pattern = { "typescript", "typescriptreact" },
  callback = function()
    -- Mimics Prettier rules:
    vim.opt_local.expandtab = true -- "useTabs": false
    vim.opt_local.tabstop = 2 -- "tabWidth": 2
    vim.opt_local.shiftwidth = 2 -- "tabWidth": 2
    vim.opt_local.softtabstop = 2 -- "tabWidth": 2
    vim.opt_local.autoindent = true

    -- Optional: Format line width like "printWidth": 80
    vim.opt_local.textwidth = 80

    -- Optional: highlight lines longer than 80 chars
    vim.opt_local.colorcolumn = "81"
  end,
})
