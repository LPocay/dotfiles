return {
  'prichrd/netrw.nvim',
  config = function()
    vim.g.netrw_list_hide = '.*\\.\\(git/\\|DS_Store\\)$'
    require('netrw').setup(
      {
        use_devicons = true
      }
    )
  end
}
