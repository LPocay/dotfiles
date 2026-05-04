return {
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        lazy = true,
        opts = {
            mappings = {
                expand = { "<CR>", "<2-LeftMouse>" },
                open = "o",
                remove = "d",
                edit = "e",
                toggle = "t",
            },
            layouts = {
                {
                    elements = {
                        { id = "repl", size = 0.30 },
                        { id = "console", size = 0.70 },
                    },
                    size = 0.19,
                    position = "bottom",
                },
                {
                    elements = {
                        { id = "scopes", size = 0.30 },
                        { id = "breakpoints", size = 0.20 },
                        { id = "stacks", size = 0.10 },
                        { id = "watches", size = 0.30 },
                    },
                    size = 0.20,
                    position = "left",
                },
            },
            controls = {
                enabled = true,
                element = "repl",
                icons = {
                    pause = "",
                    play = "",
                    step_into = "",
                    step_over = "",
                    step_out = "󰆸",
                    step_back = "",
                    run_last = "",
                    terminate = "󰅙",
                },
            },
            floating = {
                max_height = 0.9,
                max_width = 0.5,
                border = vim.g.border_chars,
                mappings = {
                    close = { "q", "<Esc>" },
                },
            },
        },
        config = function(_, opts)
            require("dapui").setup(opts)
            vim.fn.sign_define(
                "DapBreakpoint",
                { text = "", texthl = "", linehl = "", numhl = "" }
            )
            local dap = require("dap")

            -- 🐞 Debugging (nvim-dap)
            vim.keymap.set(
                "n",
                "<F5>",
                dap.continue,
                { desc = " Start/Continue Debugging" }
            )
            vim.keymap.set(
                "n",
                "<F10>",
                dap.step_over,
                { desc = " Step Over" }
            )
            vim.keymap.set(
                "n",
                "<F11>",
                dap.step_into,
                { desc = " Step Into" }
            )
            vim.keymap.set(
                "n",
                "<F12>",
                dap.step_out,
                { desc = " Step Out" }
            )

            vim.keymap.set(
                "n",
                "<leader>bt",
                dap.terminate,
                { desc = " Terminate Debugging" }
            )
            vim.keymap.set(
                "n",
                "<leader>b",
                dap.toggle_breakpoint,
                { desc = " Toggle Breakpoint" }
            )

            local dapui = require("dapui")
            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end
        end,
    },
}
