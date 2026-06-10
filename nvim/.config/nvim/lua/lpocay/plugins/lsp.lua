vim.pack.add { 'https://github.com/j-hui/fidget.nvim' }
require('fidget').setup {}

local servers = {
  clangd = {},
  gopls = {},
  pyright = {},
  rust_analyzer = {},
  ts_ls = {},
  stylua = {},
  svelte = {},
  emmet_language_server = {},
  neocmake = {},
  html = {},
  tailwindcss = {},
  cssls = {},
  prettier = {},
  ols = {},
  zls = {},
  astro = {
    before_init = function(_, config)
      local tsdk = vim.tbl_get(config, 'init_options', 'typescript', 'tsdk') or ''
      if tsdk == '' then config.init_options.typescript.tsdk = vim.fn.stdpath 'data' .. '/mason/packages/astro-language-server/node_modules/typescript/lib' end
    end,
  },
  lua_ls = {
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
      end

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          version = 'LuaJIT',
          path = { 'lua/?.lua', 'lua/?/init.lua' },
        },
        workspace = {
          checkThirdParty = false,
          library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
            '${3rd}/luv/library',
            '${3rd}/busted/library',
          }),
        },
      })
    end,
    ---@type lspconfig.settings.lua_ls
    settings = {
      Lua = {
        format = { enable = false }, -- Disable formatting (formatting is done by stylua)
      },
    },
  },
}

vim.pack.add {
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
}

require('mason').setup {}

local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  -- You can add other tools here that you want Mason to install
})

require('mason-tool-installer').setup { ensure_installed = ensure_installed }

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end
