vim.pack.add {
  'https://github.com/saghen/blink.lib',
  'https://github.com/saghen/blink.cmp',
  'https://github.com/rafamadriz/friendly-snippets',
}

local cmp = require 'blink.cmp'
local ok, err = pcall(function()
  local built, build_err = cmp.build():pwait(60000)
  if not built then error(build_err) end
end)
local implementation = cmp.library_available() and 'rust' or 'lua'
if not ok or implementation == 'lua' then
  vim.notify('Blink: ' .. tostring(err or 'Rust library unavailable') .. '. Matcher: ' .. implementation .. '.', vim.log.levels.WARN)
end
cmp.setup {
  keymap = { preset = 'default' },
  completion = { documentation = { auto_show = false } },
  sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
  fuzzy = { implementation = implementation },
  signature = { enabled = true },
  appearance = {
    nerd_font_variant = 'mono',
  },
}
