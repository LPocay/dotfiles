local function footer()
  local datetime = os.date(" %d-%m-%Y   %H:%M:%S")
  local stats = require("lazy").stats()
  local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
  return datetime
    .. "  󰋚 "
    .. vim.version().major
    .. "."
    .. vim.version().minor
    .. "."
    .. vim.version().patch
    .. " "
    .. "⚡ Loaded "
    .. stats.loaded
    .. "/"
    .. stats.count
    .. " plugins in "
    .. ms
    .. "ms"
end

return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {
      "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
      "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
      "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
      "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
      "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
      "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
      "               ╦  ╔═╗╔═╗╔═╗╔═╗╦ ╦                 ",
      "            💀 ║  ╠═╝║ ║║  ╠═╣╚╦╝ 💀              ",
      "               ╩═╝╩  ╚═╝╚═╝╩ ╩ ╩                  ",
    }
    dashboard.section.buttons.val = {
      dashboard.button("<leader>pf", " 󰈞  Find file"),
      dashboard.button("<leader>pg", "   Find git file"),
      dashboard.button("<leader>ps", "   Find word"),
      dashboard.button("<leader>pv", "   Project View"),
      dashboard.button("<leader>gg", "   Lazy Git"),
      dashboard.button("<leader>r", " 󰋚  Recent files", ":Telescope oldfiles<CR>", { desc = "󰋚  Recent files" }),
      dashboard.button("q", " 󰠛  Quit NVIM", ":qa<CR>"),
    }
    dashboard.section.footer.val = { footer() }
    alpha.setup(dashboard.opts)
  end,
}
