# Neovim Config Improvements

Review date: 2026-05-05

This file tracks improvement ideas for later review. No config changes were made when this report was created.

## Current Baseline

- Neovim version checked: `NVIM v0.12.2`.
- Plugin manager: `lazy.nvim`.
- LSP setup already uses the modern native API: `vim.lsp.config()` and `vim.lsp.enable()`.
- Treesitter health check completed successfully.
- LSP health check completed, with warnings mostly related to unknown optional filetypes from server configs.

## Highest Priority

### Add deterministic tool installation

The config enables many LSP servers in `after/plugin/lsp.lua`, but `lua/plugins/utility/mason.lua` only configures Mason itself. There is no automated install management for LSP servers, formatters, linters, or debug adapters.

Recommended direction:

- Add `mason-lspconfig.nvim` for LSP server installation.
- Add `WhoIsSethDaniel/mason-tool-installer.nvim` or equivalent for formatters, linters, and DAP adapters.
- Explicitly ensure tools such as `lua_ls`, `clangd`, `gopls`, `pyright`, `rust_analyzer`, `tailwindcss`, `zls`, `stylua`, `black`, `prettier`, `biome`, `cmake_format`, `dlv`, `js-debug-adapter`, and `cpptools`.

Why:

- Makes the config reproducible on new machines.
- Avoids silent LSP/formatter failures when a binary is missing.

### Make lint detection project-aware

`lua/plugins/linting/nvim-lint.lua` computes enabled linters once at startup based on the current working directory.

Problem:

- If Neovim starts outside a project root, or if the user switches projects during a session, Biome/ESLint detection can be wrong.

Recommended direction:

- Resolve the project root per buffer using `vim.fs.root()`.
- Detect `biome.json`, `biome.jsonc`, `eslint.config.js`, `eslint.config.mjs`, or related files from the buffer path.
- Compute or dispatch linters inside the lint autocmd instead of only at startup.

### Remove duplicated keymaps

Several plugins define mappings in both Lazy's `keys` table and again inside `config()`.

Files to review:

- `lua/plugins/editor/harpoon.lua`
- `lua/plugins/editor/neotest.lua`
- `lua/plugins/debbuging/dap.lua`
- `lua/plugins/debbuging/dap-ui.lua`
- `lua/plugins/ai/opencode.lua`

Recommended direction:

- Prefer Lazy's `keys` table for mappings that trigger plugin loading.
- Keep `config()` focused on plugin setup and runtime listeners.

Why:

- Cleaner ownership of mappings.
- Better lazy-loading behavior.
- Less risk of silently overriding mappings later.

## LSP Improvements

The current LSP architecture is modern and should be kept.

Recommended refinements:

- Move LSP setup from `after/plugin/lsp.lua` into `lua/config/lsp.lua` or into the `nvim-lspconfig` plugin spec for clearer ownership.
- Add per-server configuration where needed instead of keeping everything in one enable list.
- Consider adding filetype detection plugins only for filetypes actually used, such as `mdx`, `ejs`, `hbs`, `gotmpl`, or `postcss`.
- Keep `vim.lsp.config()` and `vim.lsp.enable()` rather than reverting to the older `require("lspconfig").server.setup()` pattern.

Health notes:

- LSP health reported warnings for unknown optional filetypes, mostly from server defaults.
- These warnings are only important if those filetypes are part of normal work.

## Treesitter Improvements

`lua/plugins/editor/treesitter.lua` currently has both `lazy = false` and `event = { "BufReadPre" }`.

Recommended direction:

- Choose one loading strategy.
- If startup performance matters, remove `lazy = false` and rely on `BufReadPre`.
- If immediate startup loading is preferred, remove the event for clarity.

Treesitter health status:

- Runtime ABI is OK.
- Parser directory is writable and in `runtimepath`.
- Installed parser health is generally good.

## Lazy.nvim Improvements

The Lazy setup in `lua/config/lazy.lua` is intentionally minimal.

Recommended additions:

- Add `checker` configuration for plugin update checks.
- Decide whether custom plugins should default to lazy loading.
- Disable unused built-in runtime plugins such as `gzip`, `tarPlugin`, `tohtml`, `tutor`, and `zipPlugin` if not needed.
- Consider adding import comments or grouping conventions to keep plugin ownership obvious.

Reference patterns:

- LazyVim uses structured Lazy defaults, update checking, and performance options.
- AstroNvim uses Lazy heavily for plugin lifecycle and overrides.
- Kickstart keeps the setup smaller but well documented.

## Editor Option Improvements

Current option file: `lua/config/set.lua`.

Options worth considering:

- `vim.opt.undofile = true` for persistent undo.
- `vim.opt.splitright = true` and `vim.opt.splitbelow = true` for predictable split placement.
- `vim.opt.ignorecase = true` plus `vim.opt.smartcase = true` for better searching.
- `vim.opt.clipboard = "unnamedplus"` if system clipboard should be the default.
- `vim.opt.mouse = "a"` if mouse support is desired for resizing splits and interacting with floating windows.

Current preference note:

- `vim.opt.mouse = ""` intentionally disables mouse support. Keep it if this is preferred.

## Formatting Improvements

Current formatter config: `lua/plugins/formatting/conform.lua`.

Recommended direction:

- Decide whether to enable format-on-save.
- If enabled, use a timeout and consider per-filetype/project exclusions.
- Add formatters for common languages used regularly, such as Go, Rust, CSS, HTML, Markdown, YAML, and shell scripts.
- Keep `lsp_format = "fallback"` unless there is a specific reason to force LSP formatting.

## Plugin-Specific Notes

### blink.cmp

Current setup is compact and works with LSP capabilities.

Possible improvements:

- Review keymap preset and completion behavior.
- Add lazydev as a completion source if desired for Lua development.
- Consider explicit appearance and documentation window behavior.

### Snacks

Snacks is used well as the central picker.

Possible improvements:

- Remove duplicate `<leader>sb` mapping in `lua/plugins/editor/snacks.lua`.
- Consider enabling additional Snacks modules only if needed.
- Keep picker mappings grouped consistently.

### DAP

Current setup supports C++, Node/TypeScript, JavaScript, and Go.

Possible improvements:

- Move DAP signs and keymaps into one owner.
- Let `nvim-dap-ui` own only UI setup and listeners.
- Use Mason-managed debug adapter paths rather than hardcoding Mason bin paths where possible.

### Neotest

Current setup includes Go and Vitest adapters.

Possible improvements:

- Remove duplicate mappings from `config()`.
- Add output/output-panel keymaps if frequently used.
- Add filetype-based lazy loading if startup cost becomes noticeable.

## Suggested Implementation Order

1. Add Mason tool installation management.
2. Make lint and formatter decisions buffer-root aware.
3. Remove duplicate keymaps.
4. Clean up Lazy defaults, checker, and performance config.
5. Add durable editor options such as persistent undo and split behavior.
6. Revisit optional plugins such as `which-key.nvim`, `guess-indent.nvim`, or extra filetype support.

## References

- Neovim LSP docs: https://neovim.io/doc/user/lsp.html
- nvim-lspconfig: https://github.com/neovim/nvim-lspconfig
- LazyVim: https://github.com/LazyVim/LazyVim
- LazyVim Lazy config docs: https://www.lazyvim.org/configuration/lazy.nvim
- kickstart.nvim: https://github.com/nvim-lua/kickstart.nvim
- AstroNvim: https://github.com/AstroNvim/AstroNvim
- AstroNvim plugin customization docs: https://docs.astronvim.com/configuration/customizing_plugins/
