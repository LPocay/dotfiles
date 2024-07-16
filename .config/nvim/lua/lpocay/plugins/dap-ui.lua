return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    keys = {
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        silent = true,
      },
    },
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
            { id = "repl",    size = 0.30 },
            { id = "console", size = 0.70 },
          },
          size = 0.19,
          position = "bottom",
        },
        {
          elements = {
            { id = "scopes",      size = 0.30 },
            { id = "breakpoints", size = 0.20 },
            { id = "stacks",      size = 0.10 },
            { id = "watches",     size = 0.30 },
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
        }
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
      vim.fn.sign_define('DapBreakpoint', { text = '', texthl = '', linehl = '', numhl = '' })
      vim.keymap.set('n', '<F5>', require 'dap'.continue)
      vim.keymap.set('n', '<F10>', require 'dap'.step_over)
      vim.keymap.set('n', '<F11>', require 'dap'.step_into)
      vim.keymap.set('n', '<F12>', require 'dap'.step_out)
      vim.keymap.set('n', '<leader>bt', require 'dap'.terminate)
      vim.keymap.set('n', '<leader>b', require 'dap'.toggle_breakpoint)
      local dap, dapui = require("dap"), require("dapui")
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
  }
}
