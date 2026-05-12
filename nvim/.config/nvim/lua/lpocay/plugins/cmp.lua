vim.pack.add {
  'https://github.com/saghen/blink.cmp',
  'https://github.com/saghen/blink.lib',
  'https://github.com/rafamadriz/friendly-snippets',
}

local cmp = require 'blink.cmp'
cmp.build():wait(60000)
cmp.setup {
  keymap = { preset = 'default' },
  completion = { documentation = { auto_show = false } },
  sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
  fuzzy = { implementation = 'rust' },
  signature = { enabled = true },
  appearance = {
    nerd_font_variant = 'mono',
  },
}
