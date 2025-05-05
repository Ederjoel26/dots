return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    size = 15, -- Default terminal height
    open_mapping = [[<leader>t]], -- Press <leader>tt to open
    insert_mappings = false,
    shade_terminals = true,
    direction = "float", -- Options: "horizontal", "vertical", "float"
    shell = "pwsh.exe",
    float_opts = {
      width = 120,
      height = 40,
    },
  },
}
