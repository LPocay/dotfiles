vim.pack.add { 'https://github.com/Civitasv/cmake-tools.nvim' }

require('cmake-tools').setup {
  cmake_use_preset = true,
  cmake_regenerate_on_save = false,
  cmake_dap_configuration = {
    name = 'CMake: GDB',
    type = 'gdb',
    request = 'launch',
  },
}

local map = function(keys, command, desc)
  vim.keymap.set('n', keys, '<cmd>wall<cr><cmd>' .. command .. '<cr>', { desc = desc })
end

map('<leader>cg', 'CMakeGenerate', 'CMake: configure')
map('<leader>cb', 'CMakeBuild', 'CMake: build')
map('<leader>cr', 'CMakeRun', 'CMake: build and run')
map('<leader>cd', 'CMakeDebug', 'CMake: build and debug')
vim.keymap.set('n', '<leader>cp', '<cmd>CMakeSelectConfigurePreset<cr>', { desc = 'CMake: select configure preset' })
vim.keymap.set('n', '<leader>cP', '<cmd>CMakeSelectBuildPreset<cr>', { desc = 'CMake: select build preset' })
