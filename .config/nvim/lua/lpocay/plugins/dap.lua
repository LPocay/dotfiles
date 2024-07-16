return {
  'mfussenegger/nvim-dap',
  dependencies = { "rcarriga/nvim-dap-ui" },
  config = function()
    local dap = require("dap")
    local cpp_config = require("lpocay.configs.dap.cpp")
    local node_config = require("lpocay.configs.dap.node")
    local go_config = require("lpocay.configs.dap.go")
    -- Cpp configurations
    dap.adapters.cppdbg = cpp_config.cppdbg_config
    dap.configurations.cpp = cpp_config.cpp_config
    -- Node configurations
    dap.adapters["pwa-node"] = node_config.pwa_node
    dap.configurations.typescript = node_config.typescript
    dap.configurations.javascript = node_config.javascript
    -- Go configurations
    dap.adapters.delve = go_config.delve
    dap.configurations.go = go_config.go

    local dapui = require("dapui")

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end
  end
}
