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
        vim.keymap.set("n", "<leader>a", function()
            harpoon:list():add()
        end, { desc = " Add file to Harpoon" })
        vim.keymap.set("n", "<C-e>", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { desc = " Toggle Harpoon menu" })

        --  Navigate Harpoon list
        vim.keymap.set("n", "H", function()
            harpoon:list():prev()
        end, { desc = " Previous Harpoon file" })
        vim.keymap.set("n", "L", function()
            harpoon:list():next()
        end, { desc = " Next Harpoon file" })
    end,
}
