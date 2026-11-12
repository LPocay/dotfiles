vim.pack.add { 'https://github.com/rebelot/kanagawa.nvim' }
vim.pack.add { 'https://github.com/zaldih/themery.nvim' }
vim.pack.add { 'https://github.com/oskarnurm/koda.nvim' }

local themery = require 'themery'
themery.setup {
  themes = {
    { name = 'Kanagawa Dragon', colorscheme = 'kanagawa-dragon' },
    { name = 'Kanagawa Wave', colorscheme = 'kanagawa-wave' },
    { name = 'Kanagawa Lotus', colorscheme = 'kanagawa-lotus' },
    { name = 'Koda Dark', colorscheme = 'koda-dark' },
    { name = 'Koda Light', colorscheme = 'koda-light' },
    { name = 'Koda Moss', colorscheme = 'koda-moss' },
    { name = 'Koda Glade', colorscheme = 'koda-glade' },
  },
  livePreview = true,
}

-- Themery only falls back to a default when a saved theme fails to load.
-- On a fresh install, apply and persist the first entry (Dragon).
if vim.g.colors_name == nil then themery.setThemeByIndex(1, true) end

vim.keymap.set('n', '<leader>tt', '<cmd>Themery<CR>', { desc = '[T]heme swi[t]cher' })
