local lsp_ensure_installed = require('lpocay.configs.lsp.ensure_installed')

return {
  'VonHeikemen/lsp-zero.nvim',
  branch = 'v4.x',
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
    local lsp_attach = function(client, bufnr)
      lsp_zero.default_keymaps({ buffer = bufnr })
      if client.supports_method('textDocument/formatting') then
        lsp_zero.buffer_autoformat()
      end
    end

    lsp_zero.extend_lspconfig({
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
      lsp_attach = lsp_attach,
      float_border = 'rounded',
      sign_text = true,
    })

    lsp_zero.set_sign_icons({
      error = '',
      warn = '',
      hint = '',
      info = ''
    })

    require('mason').setup({})
    local nvim_lsp = require('lspconfig')
    require('mason-lspconfig').setup({
      automatic_installation = false,
      ensure_installed = lsp_ensure_installed,
      handlers = {
        function(server_name)
          nvim_lsp[server_name].setup({})
        end,
        lua_ls = function()
          local lua_ls = require('lpocay.configs.lsp.lua_ls')
          nvim_lsp.lua_ls.setup(lua_ls)
        end,
        ts_ls = function()
          local ts_ls = require('lpocay.configs.lsp.ts_ls')
          nvim_lsp.ts_ls.setup(ts_ls)
        end,
        clangd = function()
          local clangd = require('lpocay.configs.lsp.clangd')
          nvim_lsp.clangd.setup(clangd)
        end,
        svelte = function()
          local svelte = require('lpocay.configs.lsp.svelte')
          nvim_lsp.svelte.setup(svelte)
        end,
        cmake = function()
          local cmake = require('lpocay.configs.lsp.cmake')
          nvim_lsp.neocmake.setup(cmake)
        end,
        denols = function()
          local deno = require('lpocay.configs.lsp.deno')
          nvim_lsp.denols.setup(deno)
        end
      }
    })

    local cmp = require('cmp')
    local cmp_format = lsp_zero.cmp_format({})
    cmp.setup({
      formatting = cmp_format,
      mapping = cmp.mapping.preset.insert({
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
        ['<C-Space>'] = cmp.mapping.complete(),
      }),
      sources = {
        { name = 'nvim_lsp' },
      },
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
    })
  end
}
