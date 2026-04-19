return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  event = { "BufReadPre" },
  config = function()
    require("nvim-treesitter").setup({})
    require("nvim-treesitter").install{
      "javascript",
      "typescript",
      "cpp",
      "c",
      "lua",
      "vim",
      "vimdoc",
      "query",
      "rust",
      "html",
      "css",
      "go",
      "svelte",
      "json",
      "yaml",
      "toml",
      "regex",
      "bash",
      "markdown",
      "markdown_inline",
    }
  end,
}
