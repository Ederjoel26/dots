local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>')

map('n', '<leader>e', vim.cmd.Ex, { desc = 'Open file explorer' })
map(
  'n',
  '<leader>q',
  vim.diagnostic.setloclist,
  { desc = 'Open diagnostic [Q]uickfix list' }
)

map('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
map('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
map('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
map('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
map('n', '<C-w>-', '<cmd>split<CR>', { desc = 'Horizontal split' })
map('n', '<C-w>|', '<cmd>vsplit<CR>', { desc = 'Vertical split' })
map('n', '<C-=>', '<cmd>resize +5<CR>', { desc = 'Increase window height' })
map('n', '<C-->', '<cmd>resize -5<CR>', { desc = 'Decrease window height' })

vim.api.nvim_set_keymap(
  'n',
  'gd',
  '<cmd>lua vim.lsp.buf.definition()<CR>',
  { noremap = true, silent = true }
)

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup(
    'kickstart-highlight-yank',
    { clear = true }
  ),
  callback = function()
    vim.highlight.on_yank()
  end,
})
