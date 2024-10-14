return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    view = {
      side = "right",
      width = 30,
      preserve_window_proportions = true,
    },
    filters = {
      dotfiles = false,
    },
    renderer = {
      root_folder_label = false,
      highlight_git = true,
      icons = {
        glyphs = {
          default = "󰈚",
          folder = {
            default = "",
            empty = "",
            empty_open = "",
            open = "",
            symlink = "",
          },
          git = { unmerged = "" },
        },
      },
    }
  }
}
