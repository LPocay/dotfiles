return {
  cppdbg_config = {
    type = 'executable',
    id = "cppdbg",
    command = vim.fn.stdpath('data') .. [[/mason/bin/OpenDebugAD7]],
  },
  cpp_config = {
    {
      name = "Launch file",
      type = "cppdbg",
      request = "launch",
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
      setupCommands = {
        {
          description = "Enable pretty-printing for gdb",
          text = "-enable-pretty-printing",
          ignoreFailures = true,
        }
      },
      stopAtEntry = true,
    },
  }
}
