return {
  pwa_node = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = {
      command = vim.fn.stdpath('data') .. [[/mason/bin/js-debug-adapter]],
      args = { "${port}" },
    }
  },
  typescript = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Docker: Attach to Node",
      remoteRoot = "/api/",
      address = "localhost",
      port = 9229,
      sourceMaps = true,
      restart = true,
      localRoot = "${workspaceFolder}"
    }
  },
  javascript = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
  },
}
