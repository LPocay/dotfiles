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

-- Native mapping descriptions take precedence over generated clues.
-- Wait for runtime plugins (including Matchit) to create their mappings.
vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('lpocay-keymap-descriptions', { clear = true }),
  once = true,
  desc = 'Give native mappings readable descriptions',
  callback = function()
    local describe = function(modes, keys, desc)
      for _, mode in ipairs(modes) do
        if vim.fn.maparg(keys, mode) ~= '' then clue.set_mapping_desc(mode, keys, desc) end
      end
    end

    local lsp_descriptions = {
      gO = 'List document symbols',
      gra = 'Code actions',
      gri = 'Go to implementation',
      grn = 'Rename symbol',
      grr = 'Find references',
      grt = 'Go to type definition',
      grx = 'Run code lens',
    }
    for keys, desc in pairs(lsp_descriptions) do
      describe({ 'n', 'x' }, keys, desc)
    end

    describe({ 'n', 'x', 'o' }, '%', 'Go to matching group')
    describe({ 'n', 'x', 'o' }, 'g%', 'Go to previous matching group')
    describe({ 'n', 'x', 'o' }, '[%', 'Go to previous unmatched group')
    describe({ 'n', 'x', 'o' }, ']%', 'Go to next unmatched group')
    describe({ 'x', 'o' }, 'a%', 'Select matching group')

    local navigation = {
      { 'b', 'Go to previous buffer', 'Go to next buffer' },
      { 'B', 'Go to first buffer', 'Go to last buffer' },
      { 'a', 'Go to previous argument file', 'Go to next argument file' },
      { 'A', 'Go to first argument file', 'Go to last argument file' },
      { 'q', 'Go to previous quickfix entry', 'Go to next quickfix entry' },
      { 'Q', 'Go to first quickfix entry', 'Go to last quickfix entry' },
      { '<C-q>', 'Go to previous quickfix file', 'Go to next quickfix file' },
      { 'l', 'Go to previous location-list entry', 'Go to next location-list entry' },
      { 'L', 'Go to first location-list entry', 'Go to last location-list entry' },
      { '<C-l>', 'Go to previous location-list file', 'Go to next location-list file' },
      { 't', 'Go to previous tag', 'Go to next tag' },
      { 'T', 'Go to first tag', 'Go to last tag' },
      { '<C-t>', 'Preview previous tag', 'Preview next tag' },
    }
    for _, entry in ipairs(navigation) do
      describe({ 'n' }, '[' .. entry[1], entry[2])
      describe({ 'n' }, ']' .. entry[1], entry[3])
    end
  end,
})

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
