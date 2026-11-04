vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/leoluz/nvim-dap-go',
}

local dap = require 'dap'
local dapui = require 'dapui'

local function project_root() return vim.fs.root(0, { 'package.json', 'go.mod', 'Cargo.toml', 'CMakeLists.txt', 'Makefile', '.git' }) or vim.fn.getcwd() end

local function prompt_path(prompt, default)
  local path = vim.fn.input { prompt = prompt, default = default, completion = 'file' }
  return path ~= '' and vim.fn.fnamemodify(path, ':p') or dap.ABORT
end

local function browser_executable()
  for _, command in ipairs { 'google-chrome-stable', 'google-chrome', 'chromium', 'chromium-browser', 'brave' } do
    local path = vim.fn.exepath(command)
    if path ~= '' then return path end
  end
  vim.notify('DAP: install Chrome/Chromium or set runtimeExecutable in .vscode/launch.json.', vim.log.levels.ERROR)
  return dap.ABORT
end

-- Mason adds these executables to Neovim's PATH during LSP setup.
for _, adapter in ipairs { 'pwa-node', 'pwa-chrome' } do
  dap.adapters[adapter] = {
    type = 'server',
    host = '127.0.0.1',
    port = '${port}',
    executable = {
      command = 'js-debug-adapter',
      args = { '${port}', '127.0.0.1' },
    },
    enrich_config = function(config, on_config)
      -- The standalone JS adapter needs this to predict TypeScript breakpoints
      -- before the generated JavaScript runs. VS Code normally supplies it.
      local final_config = vim.deepcopy(config)
      final_config.__workspaceFolder = final_config.__workspaceFolder or project_root()
      on_config(final_config)
    end,
  }
end
-- Accept the common VS Code adapter names in project launch.json files.
dap.adapters.node = dap.adapters['pwa-node']
dap.adapters.chrome = dap.adapters['pwa-chrome']

local web_filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'svelte', 'vue', 'astro' }
for _, filetype in ipairs(web_filetypes) do
  dap.configurations[filetype] = {
    {
      name = 'Browser: launch Chrome/Chromium',
      type = 'pwa-chrome',
      request = 'launch',
      runtimeExecutable = browser_executable,
      url = function()
        local url = vim.fn.input('Dev server URL: ', 'http://localhost:5173')
        return url ~= '' and url or dap.ABORT
      end,
      webRoot = project_root,
      cwd = project_root,
      sourceMaps = true,
    },
    {
      name = 'Node: launch JavaScript file (build TypeScript first)',
      type = 'pwa-node',
      request = 'launch',
      program = function()
        local file = vim.api.nvim_buf_get_name(0)
        local default = file:match '%.[cm]?js$' and file or project_root() .. '/dist/'
        return prompt_path('JavaScript entry point: ', default)
      end,
      cwd = project_root,
      console = 'integratedTerminal',
      sourceMaps = true,
      outFiles = function() return { project_root() .. '/**/*.js', project_root() .. '/**/*.mjs', project_root() .. '/**/*.cjs', '!**/node_modules/**' } end,
      skipFiles = { '<node_internals>/**' },
    },
    {
      name = 'Node: attach to inspector',
      type = 'pwa-node',
      request = 'attach',
      address = '127.0.0.1',
      port = function()
        local port = tonumber(vim.fn.input('Node inspector port: ', '9229'))
        if port and port > 0 and port < 65536 and port % 1 == 0 then return port end
        return dap.ABORT
      end,
      cwd = project_root,
      sourceMaps = true,
      skipFiles = { '<node_internals>/**' },
    },
  }
end

require('dap-go').setup {}

dap.adapters.codelldb = {
  type = 'server',
  host = '127.0.0.1',
  port = '${port}',
  executable = {
    command = 'codelldb',
    args = { '--port', '${port}' },
  },
}
dap.adapters.lldb = dap.adapters.codelldb

for _, filetype in ipairs { 'c', 'cpp', 'rust' } do
  dap.configurations[filetype] = {
    {
      name = 'Launch compiled executable',
      type = 'codelldb',
      request = 'launch',
      program = function()
        local directory = filetype == 'rust' and '/target/debug/' or '/build/'
        return prompt_path('Executable (build with debug symbols first): ', project_root() .. directory)
      end,
      cwd = project_root,
      stopOnEntry = false,
      sourceLanguages = filetype == 'rust' and { 'rust' } or nil,
    },
    {
      name = 'Attach to process',
      type = 'codelldb',
      request = 'attach',
      pid = require('dap.utils').pick_process,
      cwd = project_root,
      sourceLanguages = filetype == 'rust' and { 'rust' } or nil,
    },
  }
end

dapui.setup {}
dap.listeners.after.event_initialized.dapui_config = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticError' })
vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DiagnosticWarn' })
vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticOk', linehl = 'Visual' })

local map = function(keys, action, desc) vim.keymap.set('n', keys, action, { desc = desc }) end
map('<F5>', dap.continue, 'Debug: start / continue')
map('<F9>', dap.toggle_breakpoint, 'Debug: toggle breakpoint')
map('<F10>', dap.step_over, 'Debug: step over')
map('<F11>', dap.step_into, 'Debug: step into')
map('<F12>', dap.step_out, 'Debug: step out')
map('<leader>Dc', dap.continue, 'Debug: start / continue')
map('<leader>Db', dap.toggle_breakpoint, 'Debug: toggle breakpoint')
map('<leader>DB', function()
  local condition = vim.fn.input 'Breakpoint condition: '
  if condition ~= '' then dap.set_breakpoint(condition) end
end, 'Debug: conditional breakpoint')
map('<leader>Do', dap.step_over, 'Debug: step over')
map('<leader>Di', dap.step_into, 'Debug: step into')
map('<leader>DO', dap.step_out, 'Debug: step out')
map('<leader>Dl', dap.run_last, 'Debug: run last configuration')
map('<leader>Dx', dap.terminate, 'Debug: terminate session')
map('<leader>Du', dapui.toggle, 'Debug: toggle panels')
map('<leader>Dr', dap.repl.toggle, 'Debug: toggle REPL')
vim.keymap.set({ 'n', 'x' }, '<leader>De', function() dapui.eval() end, { desc = 'Debug: evaluate expression / selection' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  group = vim.api.nvim_create_augroup('lpocay-dap-go', { clear = true }),
  callback = function(event)
    vim.keymap.set('n', '<leader>Dt', function() require('dap-go').debug_test() end, { buffer = event.buf, desc = 'Debug: nearest Go test' })
  end,
})
