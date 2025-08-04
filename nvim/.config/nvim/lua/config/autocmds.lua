vim.api.nvim_create_autocmd("FileType", {
    pattern = "json",
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.wrapmargin = 20
    end,
})
