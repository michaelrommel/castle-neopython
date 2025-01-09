local wezterm = require 'wezterm'
local config = {}

local fontname = 'VictorMono NF'
local fontsize = 17

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
	fontname = 'VictorMono NF'
	fontsize = 13
	-- config.default_domain = 'WSL:bullseye'
	config.default_domain = 'WSL:bookworm'
	-- config.initial_rows = 24
	-- config.initial_cols = 80
	config.initial_rows = 45
	config.initial_cols = 150
else
	config.initial_rows = 45
	config.initial_cols = 150
end

config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.use_fancy_tab_bar = true
config.font = wezterm.font(fontname)
config.font_rules = {
	{
		intensity = 'Normal',
		italic = false,
		font = wezterm.font {
			family = fontname,
			weight = 'Regular',
		},
	},
	{
		intensity = 'Bold',
		italic = false,
		font = wezterm.font {
			family = fontname,
			weight = 'Medium',
		},
	},
	{
		intensity = 'Half',
		italic = false,
		font = wezterm.font {
			family = fontname,
			weight = 'Light',
		},
	},
	{
		intensity = 'Normal',
		italic = true,
		font = wezterm.font {
			family = fontname,
			weight = 'Light',
			style = 'Italic',
		},
	},
	{
		intensity = 'Bold',
		italic = true,
		font = wezterm.font {
			family = fontname,
			weight = 'Medium',
			style = 'Italic',
		},
	},
	{
		intensity = 'Half',
		italic = true,
		font = wezterm.font {
			family = fontname,
			weight = 'ExtraLight',
			style = 'Italic',
		},
	},
}
config.font_size = fontsize
config.line_height = 1.00
config.bold_brightens_ansi_colors = "No"
config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_function = 'Linear',
	fade_in_duration_ms = 20,
	fade_out_function = 'Linear',
	fade_out_duration_ms = 20,
	-- target = "CursorColor",
}
config.colors = {
	visual_bell = '#202324',
}

config.treat_east_asian_ambiguous_width_as_wide = false
config.unicode_version = 9
-- config.normalize_output_to_unicode_nfc = true
config.allow_square_glyphs_to_overflow_width = "Always"
-- config.allow_square_glyphs_to_overflow_width = "Never"
-- this is needed because otherwise box drawing characters can overlap
-- e.g. when displaying a tree which causes brightness variations
config.custom_block_glyphs = true
config.freetype_load_target = "Light"
config.freetype_render_target = "Light"
-- see: https://github.com/dawikur/base16-gruvbox-scheme
-- config.color_scheme = 'Gruvbox dark, hard (base16)'
config.color_scheme = 'Gruvbox Dark Hard'
config.window_padding = {
	left = 0,
	right = 0,
	top = 3,
	bottom = 0,
}

config.color_schemes = {
	['Gruvbox Dark Hard'] = {
		foreground = "#ebdbb2",
		background = "#1d2021",
		cursor_bg = "#d5c4a1",
		cursor_border = "#ebdbb2",
		cursor_fg = "#1d2021",
		selection_bg = "#504945",
		selection_fg = "#ebdbb2",

		ansi = {
			"#1d2021",
			"#cc241d",
			"#98971a",
			"#d79921",
			"#458588",
			"#b16286",
			"#689d6a",
			"#a89984"
		},
		brights = {
			"#928374",
			"#fb4934",
			"#b8bb26",
			"#fabd2f",
			"#83a598",
			"#d3869b",
			"#8ec07c",
			"#fbf1c7"
		}
	},
}

return config
