return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")

        -- REQUIRED
        harpoon:setup()
        -- REQUIRED

        --  Harpoon (Marks / Quick Nav)
        vim.keymap.set("n", "<leader>ha", function()
            harpoon:list():add()
        end, { desc = " Add file to Harpoon" })
        vim.keymap.set("n", "<leader>hh", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { desc = " Toggle Harpoon menu" })

        --  Navigate Harpoon list
        vim.keymap.set("n", "<leader>hp", function()
            harpoon:list():prev()
        end, { desc = " Previous Harpoon file" })
        vim.keymap.set("n", "<leader>hn", function()
            harpoon:list():next()
        end, { desc = " Next Harpoon file" })
    end,
}
