return {
    "stevearc/oil.nvim",
    config = function()
        require("oil").setup({
            default_file_explorer = true,
            view_options = {
                show_hidden = true,
            },
            float = {
                padding = 4,
                border = "rounded",
                win_options = {
                    winblend = 0,
                },
            },
        })
        vim.keymap.set("n", "-", "<CMD>Oil --float<CR>")
    end,
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
}
