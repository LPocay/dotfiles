return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPre" },
  config = function()
    require 'nvim-treesitter.configs'.setup {
      ensure_installed = {
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
      },

      sync_install = false,

      auto_install = true,

      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    }
  end,
}
