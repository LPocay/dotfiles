return {
  'rebelot/kanagawa.nvim',
  lazy = false,
  priority = 1000,
  name = 'kanagawa',
  config = function()
    -- load the colorscheme here
    require('kanagawa').setup({
      overrides = function(colors)
        local theme = colors.theme
        return {
          -- EndOfBuffer = { fg = theme.ui.fg },
          NonText = { fg = theme.ui.fg },
          LspInlayHint = { fg = theme.syn.comment },
        }
      end
    })
    vim.cmd([[colorscheme kanagawa-dragon]])
  end
}
