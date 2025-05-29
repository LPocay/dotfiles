return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    { "fredrikaverpil/neotest-golang", version = "*" }
  },
  config = function()
    local neotest_golang_opts = {}
    local neotest = require("neotest")


    neotest.setup({
      adapters = {
        require("neotest-golang")(neotest_golang_opts)
      },
    })

    vim.keymap.set('n', '<leader>tr', neotest.run.run)
    vim.keymap.set('n', '<leader>tf', function()
      neotest.run.run(vim.fn.expand("%"))
    end)
    vim.keymap.set('n', '<leader>ts', neotest.summary.toggle)
  end,
}
