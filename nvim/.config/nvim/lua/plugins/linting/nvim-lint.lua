local function biomejs()
    local binary_name = "biome"

    return {
        cmd = function()
            local local_binary =
                vim.fn.fnamemodify("./node_modules/.bin/" .. binary_name, ":p")
            return vim.loop.fs_stat(local_binary) and local_binary
                or binary_name
        end,
        args = { "lint", "--reporter=github" },
        stdin = false,
        ignore_exitcode = true,
        stream = "both",
        parser = require("lint.parser").from_pattern(
            "::(.+) title=(.+),file=(.+),line=(%d+),endLine=(%d+),col=(%d+),endColumn=(%d+)::(.+)",
            {
                "severity",
                "code",
                "file",
                "lnum",
                "end_lnum",
                "col",
                "end_col",
                "message",
            },
            {
                ["error"] = vim.diagnostic.severity.ERROR,
                ["warning"] = vim.diagnostic.severity.WARN,
                ["notice"] = vim.diagnostic.severity.INFO,
            },
            { ["source"] = "biomejs" },
            { lnum_offset = 0, end_lnum_offset = 0, end_col_offset = -1 }
        ),
    }
end

local function get_linters()
    local linters = {}
    if vim.loop.fs_stat("biome.json") ~= nil then
        require("lint").linters.biomejs = biomejs()
        linters.typescript = { "biomejs" }
        linters.javascript = { "biomejs" }
        linters.svelte = { "biomejs" }
    end
    if vim.loop.fs_stat("eslint.config.js") ~= nil then
        linters.typescript = { "eslint" }
        linters.javascript = { "eslint" }
        linters.svelte = { "eslint" }
    end
    return linters
end

return {
    "mfussenegger/nvim-lint",
    opts = {},
    config = function()
        vim.api.nvim_create_autocmd(
            { "BufWritePost", "BufReadPost", "InsertLeave" },
            {
                callback = function()
                    require("lint").try_lint()
                end,
            }
        )
        require("lint").linters_by_ft = get_linters()
    end,
}
