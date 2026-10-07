vim.pack.add { 'https://github.com/stevearc/conform.nvim' }

local conform = require 'conform'
local web_tools = require 'lpocay.web-tools'
local function formatters(buf)
  local tool = web_tools.select(buf)
  return tool and tool.name == 'biome' and { 'biome-check' } or { 'prettier' }
end

conform.setup {
  notify_on_error = true,
  notify_no_formatters = true,
  default_format_opts = {
    lsp_format = 'fallback',
  },
  formatters_by_ft = {
    typescript = formatters,
    javascript = formatters,
    typescriptreact = formatters,
    javascriptreact = formatters,
    svelte = { 'prettier' },
  },
  formatters = {
    ['biome-check'] = { require_cwd = true },
    biome = { require_cwd = true },
  },
}

local pending = {}
local function usable(buf) return vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) end

local function format_buffer()
  local buf = vim.api.nvim_get_current_buf()
  if pending[buf] then
    vim.notify('Formatting/corrections are already running for this buffer.', vim.log.levels.WARN)
    return
  end
  pending[buf] = true
  local tool = web_tools.select(buf)
  local filename, filetype = vim.api.nvim_buf_get_name(buf), vim.bo[buf].filetype
  local function finish() pending[buf] = nil end
  local function format()
    if not usable(buf) or vim.api.nvim_buf_get_name(buf) ~= filename or vim.bo[buf].filetype ~= filetype then return finish() end
    local opts = { bufnr = buf, async = true }
    if web_tools.is_web_buffer(buf) then
      opts.formatters = tool and tool.name == 'biome' and { 'biome-check' } or { 'prettier' }
      opts.lsp_format = 'never'
      -- A different buffer may be in Visual mode when ESLint replies.
      local last_line = vim.api.nvim_buf_line_count(buf)
      opts.range = { start = { 1, 0 }, ['end'] = { last_line, #(vim.api.nvim_buf_get_lines(buf, -2, -1, false)[1] or '') } }
    end
    local ok, err = pcall(conform.format, opts, finish)
    if not ok then
      finish()
      vim.notify('Formatting failed: ' .. tostring(err), vim.log.levels.ERROR)
    end
  end
  if not tool or tool.name ~= 'eslint' then return format() end

  local client = vim.lsp.get_clients({ bufnr = buf, name = 'eslint' })[1]
  if not client or not client.initialized then
    finish()
    vim.notify('ESLint is selected but its client is not ready. Retry once it has attached.', vim.log.levels.WARN)
    return
  end
  local completed, request_id = false, nil
  local function failed(message)
    finish()
    vim.notify('ESLint corrections failed: ' .. message, vim.log.levels.ERROR)
  end
  local sent
  local request_ok
  request_ok, sent, request_id = pcall(client.request, client, 'workspace/executeCommand', {
    command = 'eslint.applyAllFixes',
    arguments = { { uri = vim.uri_from_bufnr(buf), version = vim.lsp.util.buf_versions[buf] } },
  }, function(err)
    if completed then return end
    completed = true
    vim.schedule(function()
      if err then return failed(err.message or tostring(err)) end
      format()
    end)
  end, buf)
  if not request_ok or not sent then
    completed = true
    failed(request_ok and 'request could not be sent' or tostring(sent))
    return
  end
  vim.defer_fn(function()
    if completed then return end
    completed = true
    if request_id then client:cancel_request(request_id) end
    failed 'timed out after 5 seconds; Prettier was not run'
  end, 5000)
end

vim.keymap.set('n', '<leader>f', format_buffer, { desc = '[F]ormat buffer and apply lint fixes' })
vim.keymap.set('x', '<leader>f', function()
  if vim.api.nvim_get_mode().mode == '\22' then
    vim.notify('Block selections cannot be formatted safely. Use a character or line selection.', vim.log.levels.WARN)
    return
  end
  local buf = vim.api.nvim_get_current_buf()
  if pending[buf] then
    vim.notify('Formatting/corrections are already running for this buffer.', vim.log.levels.WARN)
    return
  end
  local opts = { bufnr = buf, async = true }
  if web_tools.is_web_buffer(buf) then
    local tool = web_tools.select(buf)
    opts.formatters = tool and tool.name == 'biome' and { 'biome' } or { 'prettier' }
    opts.lsp_format = 'never'
  end
  pending[buf] = true
  local ok, err = pcall(conform.format, opts, function() pending[buf] = nil end)
  if not ok then
    pending[buf] = nil
    vim.notify('Formatting failed: ' .. tostring(err), vim.log.levels.ERROR)
  end
end, { desc = '[F]ormat selection only' })
