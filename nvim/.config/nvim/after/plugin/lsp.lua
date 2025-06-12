vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local map = function(keys, func, desc)
            vim.keymap.set(
                "n",
                keys,
                func,
                { buffer = event.buf, desc = "LSP: " .. desc }
            )
        end

        local builtin = require("telescope.builtin")
        map("gd", builtin.lsp_definitions, "[G]oto [D]efinition")
        map("gr", builtin.lsp_references, "[G]oto [R]eferences")
        map("gi", builtin.lsp_implementations, "[G]oto [I]mplementation")
        map("<leader>ds", builtin.lsp_document_symbols, "[D]ocument [S]ymbols")
        map(
            "<leader>ws",
            builtin.lsp_workspace_symbols,
            "[W]orkspace [S]ymbols"
        )
        map("<leader>br", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        map("<leader>bs", function()
            vim.lsp.buf.signature_help({ border = "rounded" })
        end, "[B]uffer [S]ignature")
        map("K", function()
            vim.lsp.buf.hover({ border = "rounded" })
        end, "Hover Documentation")
        map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
    end,
})

vim.lsp.config("*", {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.INFO] = "",
        },
    },
})

vim.lsp.enable({
    "lua_ls",
    "clangd",
    -- "denols",
    "neocmake",
    "svelte",
    "gopls",
    "emmet_language_server",
    "html",
    "pyright",
    "rust_analyzer",
    "tailwindcss",
    "ts_ls",
    "unocss",
    "zls",
})
