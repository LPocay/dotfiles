vim.pack.add { { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' } }

local parsers = {
  'bash',
  'c',
  'cpp',
  'diff',
  'astro',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'vim',
  'vimdoc',
  'css',
  'javascript',
  'typescript',
  'tsx',
  'jsx',
  'prisma',
  'rust',
  'go',
  'svelte',
  'json',
  'yaml',
  'toml',
  'regex',
  'dockerfile',
  'sql',
  'python',
  'xml',
  'qmljs',
  'zig',
  'odin',
}
local treesitter = require 'nvim-treesitter'
local function notify_error(message) vim.notify('Treesitter: ' .. tostring(message), vim.log.levels.ERROR) end
treesitter.install(parsers):await(function(err, success)
  if err or not success then vim.schedule(function() notify_error(err or 'some configured parsers could not be installed') end) end
end)

local function matches_buffer(buf, language)
  return vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) and vim.treesitter.language.get_lang(vim.bo[buf].filetype) == language
end

---@param buf integer
---@param language string
local function treesitter_try_attach(buf, language)
  if not matches_buffer(buf, language) then return end
  local ok, err = pcall(function()
    local loaded, load_err = vim.treesitter.language.add(language)
    if not loaded then error(load_err or ('cannot load parser ' .. language)) end
    vim.treesitter.start(buf, language)
    if vim.treesitter.query.get(language, 'indents') then vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
  end)
  if not ok then notify_error(err) end
end

local available_parsers = treesitter.get_available()
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('lpocay-treesitter', { clear = true }),
  callback = function(args)
    local buf, filetype = args.buf, args.match

    local language = vim.treesitter.language.get_lang(filetype)
    if not language then return end

    local installed_parsers = treesitter.get_installed 'parsers'

    if vim.tbl_contains(installed_parsers, language) then
      treesitter_try_attach(buf, language)
    elseif vim.tbl_contains(available_parsers, language) then
      treesitter.install(language):await(function(err, success)
        vim.schedule(function()
          if not matches_buffer(buf, language) then return end
          if err or not success then return notify_error(err or ('installation failed for ' .. language)) end
          treesitter_try_attach(buf, language)
        end)
      end)
    else
      -- Built-in/custom parsers may not be managed by nvim-treesitter.
      if vim.treesitter.language.add(language) then treesitter_try_attach(buf, language) end
    end
  end,
})
