return {
  delve = function(callback, config)
    if config.mode == 'remote' and config.request == 'attach' then
      callback({
        type = 'server',
        host = config.host or '127.0.0.1',
        port = config.port or '38697'
      })
    else
      callback({
        type = 'server',
        port = '${port}',
        executable = {
          command = 'dlv',
          args = { 'dap', '-l', '127.0.0.1:${port}', '--log', '--log-output=dap' },
          detached = vim.fn.has("win32") == 0,
        }
      })
    end
  end,
  go = {
    {
      type = "delve",
      name = "Debug",
      request = "launch",
      program = "${file}"
    },
    {
      type = "delve",
      name = "Debug test", -- configuration for debugging test files
      request = "launch",
      mode = "test",
      program = "${file}"
    },
    -- works with go.mod packages and sub packages
    {
      type = "delve",
      name = "Debug test (go.mod)",
      request = "launch",
      mode = "test",
      program = "./${relativeFileDirname}"
    },
    {
      type = "delve",
      name = "Debug API",
      request = "launch",
      mode = "debug",
      program = "${workspaceFolder}/cmd/api/"
    }
  }
}
