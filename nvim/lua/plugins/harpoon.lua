return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup()

    local map = vim.keymap.set
    map('n', '<leader>ma', function()
      harpoon:list():add()
    end)
    map('n', '<leader>ml', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end)

    map('n', '<leader>h', function()
      harpoon:list():select(1)
    end)
    map('n', '<leader>j', function()
      harpoon:list():select(2)
    end)
    map('n', '<leader>k', function()
      harpoon:list():select(3)
    end)
    -- map('n', '<C-s>', function()
    --   harpoon:list():select(4)
    -- end)

    -- Toggle previous & next buffers stored within Harpoon list
    map('n', '<C-p>', function()
      harpoon:list():prev()
    end)
    map('n', '<C-n>', function()
      harpoon:list():next()
    end)
  end,
}
