return {
    "saghen/blink.cmp",
    dependencies = {
        "rafamadriz/friendly-snippets",
        {
            "L3MON4D3/LuaSnip",
            version = "v2.*",
            name = "luasnip",
        },
        { "echasnovski/mini.icons", opts = {} },
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
            use_nvim_cmp_as_default = true,
            nerd_font_variant = "mono",
        },
        completion = {
            menu = {
                draw = {
                    components = {
                        kind_icon = {
                            text = function(ctx)
                                local kind_icon, _, _ =
                                    require("mini.icons").get("lsp", ctx.kind)
                                return kind_icon
                            end,
                            -- (optional) use highlights from mini.icons
                            highlight = function(ctx)
                                local _, hl, _ =
                                    require("mini.icons").get("lsp", ctx.kind)
                                return hl
                            end,
                        },
                        kind = {
                            -- (optional) use highlights from mini.icons
                            highlight = function(ctx)
                                local _, hl, _ =
                                    require("mini.icons").get("lsp", ctx.kind)
                                return hl
                            end,
                        },
                    },
                },
            },
        },
    },
}
