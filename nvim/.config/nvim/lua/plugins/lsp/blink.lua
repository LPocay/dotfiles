return {
  "saghen/blink.cmp",
  dependencies = {
    "rafamadriz/friendly-snippets",
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      name = "luasnip",
    },
  },
  build = "cargo build --release",
  opts = {
    snippets = {
      preset = "luasnip",
    },
    keymap = {
      ["<C-g>"] = { "show_documentation" },
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
