return {
  "saghen/blink.cmp",
  dependencies = {
    "saghen/blink.lib",
    "rafamadriz/friendly-snippets",
  },
  build = function()
    require("blink.cmp").build():wait(60000)
  end,
  opts = {
    keymap = {
      ["<C-g>"] = { "show_documentation" },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
  },
}
