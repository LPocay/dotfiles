vim.pack.add { 'https://github.com/rebelot/kanagawa.nvim' }
vim.pack.add { 'https://github.com/zaldih/themery.nvim' }
vim.pack.add { 'https://github.com/oskarnurm/koda.nvim' }
vim.pack.add { { src = 'https://github.com/rose-pine/neovim', name = 'rose-pine' } }

require('rose-pine').setup {}

local themery = require 'themery'
themery.setup {
  themes = {
    { name = 'Kanagawa Dragon', colorscheme = 'kanagawa-dragon', before = [[vim.o.background = 'dark']] },
    { name = 'Kanagawa Wave', colorscheme = 'kanagawa-wave', before = [[vim.o.background = 'dark']] },
    { name = 'Kanagawa Lotus', colorscheme = 'kanagawa-lotus', before = [[vim.o.background = 'light']] },
    { name = 'Rosé Pine', colorscheme = 'rose-pine-main', before = [[vim.o.background = 'dark']] },
    { name = 'Rosé Pine Moon', colorscheme = 'rose-pine-moon', before = [[vim.o.background = 'dark']] },
    { name = 'Rosé Pine Dawn', colorscheme = 'rose-pine-dawn', before = [[vim.o.background = 'light']] },
    { name = 'Koda Dark', colorscheme = 'koda-dark', before = [[vim.o.background = 'dark']] },
    { name = 'Koda Light', colorscheme = 'koda-light', before = [[vim.o.background = 'light']] },
    { name = 'Koda Moss', colorscheme = 'koda-moss', before = [[vim.o.background = 'dark']] },
    { name = 'Koda Glade', colorscheme = 'koda-glade', before = [[vim.o.background = 'light']] },
  },
  livePreview = true,
}

-- Themery only falls back to a default when a saved theme fails to load.
-- On a fresh install, apply and persist the first entry (Dragon).
if vim.g.colors_name == nil then themery.setThemeByIndex(1, true) end

vim.keymap.set('n', '<leader>tt', '<cmd>Themery<CR>', { desc = '[T]heme swi[t]cher' })
