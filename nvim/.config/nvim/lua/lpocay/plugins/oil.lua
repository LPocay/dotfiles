vim.pack.add { 'https://github.com/stevearc/oil.nvim' }
require('oil').setup {
  default_file_explorer = true,
  view_options = {
    show_hidden = true,
  },
  float = {
    padding = 4,
    border = 'rounded',
    win_options = {
      winblend = 0,
    },
  },
}

vim.keymap.set('n', '<leader>e', '<CMD>Oil --float<CR>', { desc = ' Explorer' })
vim.keymap.set('n', '<leader>pv', '<CMD>Oil --float<CR>', { desc = ' Project view' })
