---@type vim.lsp.Config
return {
  settings = {
    Lua = {
      telemetry = {
        enable = false
      },
      hint = {
        enable = true
      },
      completion = {
        callSnippet = "Replace"
      },
      diagnostics = {
        disable = { "missing-fields" },
      },
    }
  }
}
