local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 16
config.color_scheme = 'kanagawabones'
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
  left = '0cell',
  right = '0cell',
  top = '0cell',
  bottom = '0cell',
}

-- and finally, return the configuration to wezterm
return config
