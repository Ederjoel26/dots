return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {},
  keys = {
    {
      'zk',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').jump()
      end,
      desc = 'Flash',
    },
    -- {
    --   'Zk',
    --   mode = { 'n', 'x', 'o' },
    --   function()
    --     require('flash').treesitter()
    --   end,
    --   desc = 'Flash Treesitter',
    -- },
    -- {
    --   'x',
    --   mode = 'o',
    --   function()
    --     require('flash').remote()
    --   end,
    --   desc = 'Remote Flash',
    -- },
    -- {
    --   'X',
    --   mode = { 'o', 'x' },
    --   function()
    --     require('flash').treesitter_search()
    --   end,
    --   desc = 'Treesitter Search',
    -- },
    -- {
    --   '<c-s>',
    --   mode = { 'c' },
    --   function()
    --     require('flash').toggle()
    --   end,
    --   desc = 'Toggle Flash Search',
    -- },
  },
}
