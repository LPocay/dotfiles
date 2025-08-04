return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        {
            -- Customize or remove this keymap to your liking
            "<leader>f",
            function()
                require("conform").format({ async = true })
            end,
            mode = "",
            desc = "Format buffer",
        },
    },
    -- This will provide type hinting with LuaLS
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
        -- Define your formatters
        formatters_by_ft = {
            lua = { "stylua" },
            python = { "black" },
            typescript = { "biome-check", "prettier", stop_after_first = true },
            javascript = { "biome-check", "prettier", stop_after_first = true },
            svelte = { "biome-check", "prettier", stop_after_first = true },
            json = { "biome-check" },
            jsonc = { "biome-check" },
            cmake = { "cmake_format" },
        },
        -- Set default options
        default_format_opts = {
            lsp_format = "fallback",
        },
        -- Set up format-on-save
        -- format_on_save = { timeout_ms = 500 },
        -- Customize formatters
        formatters = {
            ["biome-check"] = {
                append_args = { "--linter-enabled=false" },
            },
        },
    },
}
