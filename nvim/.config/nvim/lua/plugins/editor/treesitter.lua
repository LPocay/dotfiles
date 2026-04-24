return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  event = { "BufReadPre" },
  config = function()
    require("nvim-treesitter").setup({})
    require("nvim-treesitter").install {
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
      "dockerfile",
      "sql",
      "python",
    }
    -- Start treesitter with error handling for unsupported filetypes
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local ok = pcall(function()
          vim.treesitter.start(args.buf)
        end)
        if not ok then
          -- Silently ignore if parser not found (like oil.nvim)
        end
      end,
    })
  end,
}
