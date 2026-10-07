vim.pack.add { 'https://github.com/j-hui/fidget.nvim' }
require('fidget').setup {}

local servers = {
  clangd = {},
  qmlls = { cmd = { '/usr/lib/qt6/bin/qmlls' } },
  gopls = {},
  pyright = {},
  rust_analyzer = {},
  ts_ls = {},
  stylua = {},
  svelte = {},
  emmet_language_server = {},
  neocmake = {},
  html = {},
  tailwindcss = {
    filetypes = {
      'html',
      'css',
      'scss',
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
      'svelte',
      'vue',
      'astro',
    },
  },
  cssls = {},
  ols = {},
  zls = {},
  astro = {
    before_init = function(_, config)
      config.init_options = config.init_options or {}
      config.init_options.typescript = config.init_options.typescript or {}
      local opts = config.init_options.typescript
      local function valid(path) return path and path ~= '' and vim.uv.fs_stat(vim.fs.joinpath(path, 'tsserverlibrary.js')) ~= nil end
      if opts.tsdk and opts.tsdk ~= '' then
        if not valid(opts.tsdk) then vim.notify('Astro: explicit TypeScript SDK is invalid: ' .. opts.tsdk, vim.log.levels.WARN) end
        return
      end
      local local_sdk = config.root_dir and require('lspconfig.util').get_typescript_server_path(config.root_dir)
      local mason_sdk = vim.fn.stdpath 'data' .. '/mason/packages/astro-language-server/node_modules/typescript/lib'
      if valid(local_sdk) then
        opts.tsdk = local_sdk
      elseif valid(mason_sdk) then
        opts.tsdk = mason_sdk
      else
        vim.notify('Astro: no usable TypeScript SDK found in the project or Mason (tsserverlibrary.js required).', vim.log.levels.WARN)
      end
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

local web_tools = require 'lpocay.web-tools'
web_tools.setup_roots()
local web_filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }
servers.biome = {
  filetypes = web_filetypes,
  root_dir = web_tools.lsp_root 'biome',
  cmd = web_tools.lsp_command 'biome',
}
servers.eslint = {
  filetypes = vim.list_extend(vim.deepcopy(web_filetypes), { 'svelte' }),
  root_dir = web_tools.lsp_root 'eslint',
  cmd = web_tools.lsp_command 'eslint',
  settings = { run = 'onType', format = false, codeActionOnSave = { enable = false } },
}

-- Use the qmlls binary from Arch's qt6-declarative package instead of Mason's build.
local ensure_installed = vim.tbl_filter(function(name) return name ~= 'qmlls' end, vim.tbl_keys(servers))
local tools = { 'prettier', 'biome' }
ensure_installed = vim.fn.uniq(vim.fn.sort(vim.list_extend(ensure_installed, tools)))

require('mason-tool-installer').setup { ensure_installed = ensure_installed }

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end
