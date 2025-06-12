local custom_vscode = require("lualine.themes.rose-pine")
custom_vscode.normal.c.bg = "None"
return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        options = {
            theme = custom_vscode,
            disabled_filetypes = {
                "alpha",
            },
        },
    },
}
