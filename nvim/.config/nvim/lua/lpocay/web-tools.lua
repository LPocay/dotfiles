local M = {}
local web_filetypes = { javascript = true, javascriptreact = true, typescript = true, typescriptreact = true, svelte = true }
local roots = {}
local warned = {}

function M.is_web_buffer(buf) return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == '' and web_filetypes[vim.bo[buf].filetype] == true end

-- Keep nvim-lspconfig's project detection, including ESLint's monorepo support.
function M.setup_roots()
  for _, name in ipairs { 'biome', 'eslint' } do
    if not roots[name] then roots[name] = vim.lsp.config[name].root_dir end
  end
end

local function root_for(name, buf)
  local root
  if roots[name] then roots[name](buf, function(path) root = path end) end
  return root
end

function M.executable(name, root)
  if root then
    for _, dir in ipairs(vim.fs.find('node_modules', { path = root, upward = true, limit = math.huge, type = 'directory' })) do
      local path = vim.fs.joinpath(dir, '.bin', name)
      if vim.fn.executable(path) == 1 then return path end
    end
  end
  if vim.fn.executable(name) == 1 then return name end
end

function M.select(buf)
  if not M.is_web_buffer(buf) or vim.api.nvim_buf_get_name(buf) == '' then return end
  if vim.bo[buf].filetype ~= 'svelte' then
    local root = root_for('biome', buf)
    if root then
      local cmd = M.executable('biome', root)
      if cmd then return { name = 'biome', root = root, cmd = cmd } end
      if not warned[root] then
        warned[root] = true
        vim.schedule(
          function() vim.notify('Biome is configured but its executable is missing: ' .. root .. '. Trying ESLint/Prettier.', vim.log.levels.WARN) end
        )
      end
    end
  end
  local root = root_for('eslint', buf)
  if root then
    local cmd = M.executable('vscode-eslint-language-server', root)
    if cmd then return { name = 'eslint', root = root, cmd = cmd } end
    if not warned['eslint:' .. root] then
      warned['eslint:' .. root] = true
      vim.schedule(function() vim.notify('ESLint is configured but its language server is missing: ' .. root, vim.log.levels.WARN) end)
    end
  end
end

function M.lsp_root(name)
  return function(buf, on_dir)
    local tool = M.select(buf)
    if tool and tool.name == name then on_dir(tool.root) end
  end
end

function M.lsp_command(name)
  return function(dispatchers, config)
    local executable = M.executable(name == 'biome' and 'biome' or 'vscode-eslint-language-server', config.root_dir)
    return vim.lsp.rpc.start({ assert(executable, name .. ' executable unavailable'), name == 'biome' and 'lsp-proxy' or '--stdio' }, dispatchers)
  end
end

return M
