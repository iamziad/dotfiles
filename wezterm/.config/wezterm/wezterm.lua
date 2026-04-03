-- WezTerm Configuration

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- -------------------------------------------------------------------
-- General
-- -------------------------------------------------------------------
config.automatically_reload_config = true
config.audible_bell = "Disabled"
config.color_scheme = "Gruvbox dark, medium (base16)"

-- -------------------------------------------------------------------
-- Fonts
-- -------------------------------------------------------------------
config.font = wezterm.font_with_fallback({
	{ family = "JetBrainsMono Nerd Font", weight = "Regular" },
	{ family = "Noto Sans Arabic", weight = "Regular" }, -- Arabic shaping + BiDi
	{ family = "Noto Sans", weight = "Regular" }, -- General Unicode fallback
})
config.font_size = 11.5

-- Ligatures
config.harfbuzz_features = { "calt=1", "liga=1", "clig=1" }

-- -------------------------------------------------------------------
-- Fonts
-- -------------------------------------------------------------------
config.keys = {
	{ key = "1", mods = "ALT", action = wezterm.action.ActivateTab(0) },
	{ key = "2", mods = "ALT", action = wezterm.action.ActivateTab(1) },
	{ key = "3", mods = "ALT", action = wezterm.action.ActivateTab(2) },
	{ key = "4", mods = "ALT", action = wezterm.action.ActivateTab(3) },
	{ key = "5", mods = "ALT", action = wezterm.action.ActivateTab(4) },
	{ key = "6", mods = "ALT", action = wezterm.action.ActivateTab(5) },
	{ key = "7", mods = "ALT", action = wezterm.action.ActivateTab(6) },
	{ key = "8", mods = "ALT", action = wezterm.action.ActivateTab(7) },
	{ key = "9", mods = "ALT", action = wezterm.action.ActivateTab(8) },
	{ key = "l", mods = "ALT", action = wezterm.action.ActivateTabRelative(1) },
	{ key = "h", mods = "ALT", action = wezterm.action.ActivateTabRelative(-1) },
}

-- -------------------------------------------------------------------
-- Arabic / BiDi
-- -------------------------------------------------------------------
config.bidi_enabled = true
config.bidi_direction = "AutoLeftToRight"

-- -------------------------------------------------------------------
-- Cursor
-- -------------------------------------------------------------------
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.force_reverse_video_cursor = false

-- -------------------------------------------------------------------
-- Window
-- -------------------------------------------------------------------
config.window_padding = {
	left = 2,
	right = 2,
	top = 2,
	bottom = 2,
}
config.window_background_opacity = 0.90
-- config.window_decorations = "NONE" -- Uncomment to hide decorations

-- -------------------------------------------------------------------
-- Scrollback
-- -------------------------------------------------------------------
config.scrollback_lines = 5000

-- -------------------------------------------------------------------
-- Performance
-- -------------------------------------------------------------------
config.animation_fps = 60
config.max_fps = 60

-- -------------------------------------------------------------------
-- Tab Bar (Gruvbox)
-- -------------------------------------------------------------------
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true

config.colors = {
	tab_bar = {
		background = "#282828",
		active_tab = {
			bg_color = "#458588",
			fg_color = "#282828",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#3c3836",
			fg_color = "#a89984",
		},
		inactive_tab_hover = {
			bg_color = "#504945",
			fg_color = "#d5c4a1",
		},
		new_tab = {
			bg_color = "#282828",
			fg_color = "#a89984",
		},
		new_tab_hover = {
			bg_color = "#3c3836",
			fg_color = "#458588",
		},
	},
}

return config
