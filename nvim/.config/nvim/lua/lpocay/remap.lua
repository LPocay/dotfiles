vim.g.mapleader = " "

local map = vim.keymap.set

map("n", "<leader>pv", vim.cmd.NvimTreeToggle)
map("n", "<leader>l", vim.cmd.Lazy)

--Lazygit
map("n", "<leader>gg", vim.cmd.LazyGit)

--Code
map("n", "<leader>cf", vim.cmd.LspZeroFormat)
map("n", "<leader>ca", vim.lsp.buf.code_action)

--Quality
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

map("x", "<leader>p", [["_dP]])

map({ "n", "v" }, "<leader>y", [["+y]])
map("n", "<leader>p", [["+p]])

map("n", "<leader>Y", [["+Y]])

map({ "n", "v" }, "<leader>d", [["_d]])

map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

map('n', '<leader>bd', [[:bd<CR>]])

-- Inlay hints
map("n", "<leader>ih", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end)

-- Tab Line
map("n", "<A-,>", vim.cmd.BufferPrevious)
map("n", "<A-.>", vim.cmd.BufferNext)
map('n', '<A-c>', vim.cmd.BufferClose)
