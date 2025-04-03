return {
  -- Plugin: oil.nvim
  -- URL: https://github.com/stevearc/oil.nvim
  -- Description: A Neovim plugin for managing and navigating directories.

  "stevearc/oil.nvim",

  lazy = false,

  opts = {
    view_options = {
      show_hidden = true,
    },
    float = {
      padding = 5,
    },
  },

  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
