local map = function (mode, lsh, command, desc)
  vim.keymap.set(mode, lsh, command, { desc = desc })
end

-- 🗂 Project / Plugin Management
map("n", "<leader>pv", "<CMD>Oil --float<CR>", " Project view")
map("n", "<leader>l", vim.cmd.Lazy, "󰒲 Lazy (plugins)")

--  Git
map("n", "<leader>gg", vim.cmd.LazyGit, " LazyGit")

--  LSP / Code
map("n", "<leader>ca", vim.lsp.buf.code_action, "󰌶 Code Action")

--  Editing / Quality of Life
map("v", "J", ":m '>+1<CR>gv=gv", " Move line down")
map("v", "K", ":m '<-2<CR>gv=gv", " Move line up")
map("x", "<leader>p", [["_dP]], " Paste without overwriting register")
map({ "n", "v" }, "<leader>y", [["+y]], "󰅍 Copy to system clipboard")
map("n", "<leader>p", [["+p]], " Paste from system clipboard")
map("n", "<leader>Y", [["+Y]], "󰅍 Copy line to system clipboard")
map({ "n", "v" }, "<leader>d", [["_d]], " Delete without overwriting register")
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], " Substitute word under cursor")
map("n", "<leader>bd", [[:bd<CR>]], " Close current buffer")

--  Inlay hints
map("n", "<leader>ih", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, " Toggle inlay hints")

--  Tabs / Buffers
map("n", "<A-,>", vim.cmd.BufferPrevious, "󰒮 Previous buffer")
map("n", "<A-.>", vim.cmd.BufferNext, "󰒭 Next buffer")
map("n", "<A-c>", vim.cmd.BufferClose, "󰅖 Close buffer")
