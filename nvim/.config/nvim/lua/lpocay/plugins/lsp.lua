local lsp_ensure_installed = require('lpocay.configs.lsp.ensure_installed')

return {
  'VonHeikemen/lsp-zero.nvim',
  branch = 'v3.x',
  dependencies = {
    -- LSP Support
    { 'neovim/nvim-lspconfig' },
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },

    -- Autocompletion
    { 'hrsh7th/nvim-cmp' },     -- Required
    { 'hrsh7th/cmp-nvim-lsp' }, -- Required
    { 'L3MON4D3/LuaSnip' },     -- Required
  },
  config = function()
    local lsp_zero = require('lsp-zero')
    lsp_zero.on_attach(function(client, bufnr)
      lsp_zero.default_keymaps({ buffer = bufnr })
      if client.supports_method('textDocument/formatting') then
        lsp_zero.buffer_autoformat()
      end
    end)

    lsp_zero.set_sign_icons({
      error = '',
      warn = '',
      hint = '',
      info = ''
    })

    require('mason').setup({})
    require('mason-lspconfig').setup({
      ensure_installed = lsp_ensure_installed,
      handlers = {
        lsp_zero.default_setup,
        lua_ls = function()
          local lua_opts = lsp_zero.nvim_lua_ls()
          require('lspconfig').lua_ls.setup(lua_opts)
        end,
      }
    })
    local cmp = require('cmp')
    local cmp_format = lsp_zero.cmp_format({})

    require('lspconfig').lua_ls.setup({
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
        }
      }
    })

    local tsserver = require('lpocay.configs.lsp.tsserver')
    require('lspconfig').tsserver.setup(tsserver)

    local clangd = require('lpocay.configs.lsp.clangd')
    require('lspconfig').clangd.setup(clangd)

    local svelte = require('lpocay.configs.lsp.svelte')
    require('lspconfig').svelte.setup(svelte)

    local cmake = require('lpocay.configs.lsp.cmake')
    require('lspconfig').neocmake.setup(cmake)

    cmp.setup({
      formatting = cmp_format,
      mapping = cmp.mapping.preset.insert({
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
        ['<C-Space>'] = cmp.mapping.complete(),
      }),
    })
  end
}
