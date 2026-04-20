vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    local builtin = require("snacks.picker")
    map("gd", builtin.lsp_definitions, "[G]oto [D]efinition")
    map("gr", builtin.lsp_references, "[G]oto [R]eferences")
    map("gi", builtin.lsp_implementations, "[G]oto [I]mplementation")
    map("gy", builtin.lsp_type_definitions, "Goto T[y]pe Definition")
    map("<leader>cs", builtin.lsp_symbols, "[C]ode [S]ymbols")
    map("<leader>cS", builtin.lsp_workspace_symbols, "[C]ode Workspace [S]ymbols")
    map("<leader>cr", vim.lsp.buf.rename, "[C]ode [R]ename")
    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
    map("<leader>ch", function()
      vim.lsp.buf.signature_help({ border = "rounded" })
    end, "[C]ode Signature [H]elp")
    map("K", function()
      vim.lsp.buf.hover({ border = "rounded" })
    end, "Hover Documentation")
    map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
  end,
})

vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
})

vim.lsp.enable({
  "lua_ls",
  "clangd",
  -- "denols",
  "neocmake",
  "svelte",
  "gopls",
  "emmet_language_server",
  "html",
  "pyright",
  "rust_analyzer",
  "tailwindcss",
  "ts_ls",
  "cssls",
  "zls",
  "elmls",
})
