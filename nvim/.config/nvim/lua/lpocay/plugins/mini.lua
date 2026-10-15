vim.pack.add { 'https://github.com/nvim-mini/mini.nvim' }

require('mini.ai').setup {
  mappings = {
    around_next = 'aa',
    inside_next = 'ii',
  },
  n_lines = 500,
}

require('mini.surround').setup()

local clue = require 'mini.clue'
clue.setup {
  triggers = {
    { mode = { 'n', 'x' }, keys = '<Leader>' },
    { mode = { 'n', 'x' }, keys = 'g' },
    { mode = { 'n', 'x' }, keys = 'z' },
    { mode = 'n', keys = '<C-w>' },
    { mode = 'n', keys = '[' },
    { mode = 'n', keys = ']' },
  },
  clues = {
    { mode = { 'n', 'x' }, keys = '<Leader>s', desc = '+Search' },
    { mode = { 'n', 'x' }, keys = '<Leader>h', desc = '+Git hunks' },
    { mode = 'n', keys = '<Leader>t', desc = '+Toggle' },
    clue.gen_clues.g(),
    clue.gen_clues.z(),
    clue.gen_clues.windows(),
    clue.gen_clues.square_brackets(),
  },
  window = {
    delay = 300,
    config = { width = 'auto' },
  },
}

local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }

require('mini.starter').setup()
