return {
  "saghen/blink.cmp",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  build = "cargo build --release",
  opts = {
    keymap = {
      ["<C-g>"] = { "show_documentation" },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    appearance = {
      use_nvim_cmp_as_default = false,
      nerd_font_variant = "mono",
    },
    signature = { window = { border = "rounded" } },
    completion = {
      documentation = {
        window = {
          border = "rounded",
        },
      },
      menu = {
        border = "rounded",
      },
    },
  },
}
