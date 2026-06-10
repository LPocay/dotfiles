do
  vim.loader.enable()
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '
  vim.g.have_nerd_font = true

  vim.o.number = true
  vim.o.mouse = 'a'
  vim.o.showmode = false

  vim.o.breakindent = true
  vim.o.undofile = true
  vim.o.signcolumn = 'yes'
  vim.o.updatetime = 250
  vim.o.timeoutlen = 300

  vim.o.splitright = true
  vim.o.splitbelow = true
  vim.o.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

  vim.o.inccommand = 'split'
  vim.o.cursorline = true
  vim.o.scrolloff = 10
  vim.o.confirm = true
  vim.o.shiftwidth = 2
  vim.o.tabstop = 2
  vim.o.expandtab = true
  vim.o.winborder = 'rounded'
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

  vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },

    virtual_text = true, -- Text shows up at the end of the line
    virtual_lines = false, -- Text shows up underneath the line, with virtual lines

    jump = {
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float {
          bufnr = bufnr,
          scope = 'cursor',
          focus = false,
        }
      end,
    },
  }

  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

  vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
  vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
  vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
  vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
  })
end

do
  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local stderr = result.stderr or ''
      local stdout = result.stdout or ''
      local output = stderr ~= '' and stderr or stdout
      if output == '' then output = 'No output from build command.' end
      vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end

  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      if kind ~= 'install' and kind ~= 'update' then return end

      if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
        run_build(name, { 'make' }, ev.data.path)
        return
      end

      if name == 'LuaSnip' then
        if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
        return
      end

      if name == 'nvim-treesitter' then
        if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
        vim.cmd 'TSUpdate'
        return
      end
    end,
  })
end

local map = function(mode, lsh, command, desc) vim.keymap.set(mode, lsh, command, { desc = desc }) end

do
  map('v', 'J', ":m '>+1<CR>gv=gv", ' Move line down')
  map('v', 'K', ":m '<-2<CR>gv=gv", ' Move line up')
  map('x', '<leader>p', [["_dP]], ' Paste without overwriting register')
  map({ 'n', 'v' }, '<leader>y', [["+y]], '󰅍 Copy to system clipboard')
  map('n', '<leader>p', [["+p]], ' Paste from system clipboard')
  map('n', '<leader>Y', [["+Y]], '󰅍 Copy line to system clipboard')
  map({ 'n', 'v' }, '<leader>d', [["_d]], ' Delete without overwriting register')
  map('n', '<leader>u', function() vim.pack.update() end, '[U]pdate packages')
  map('n', '<leader>s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], ' Substitute word under cursor')
end

-- Plugins
require 'lpocay.plugins.guess-indent'
require 'lpocay.plugins.devicons'
require 'lpocay.plugins.gisigns'
require 'lpocay.plugins.kanagawa'
require 'lpocay.plugins.todo-comments'
require 'lpocay.plugins.mini'
require 'lpocay.plugins.telescope'
require 'lpocay.plugins.lsp'
require 'lpocay.plugins.conform'
require 'lpocay.plugins.cmp'
require 'lpocay.plugins.treesitter'
require 'lpocay.plugins.oil'
