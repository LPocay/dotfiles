return {
  'stevearc/oil.nvim',
  config = function()
    require('oil').setup {
      default_file_explorer = true,
      view_options = {
        show_hidden = true,
      }
    }
    vim.keymap.set("n", "-", "<CMD>Oil --float<CR>")
  end,
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
