-- window picker for neo-tree
return {
	"s1n7ax/nvim-window-picker",
	lazy = true,
	opts = {
		show_prompt = false,
		highlights = {
			statusline = {
				focused = {
					fg = '#1d2021',
					bg = '#83a598',
					bold = true,
				},
				unfocused = {
					fg = '#ebdbb2',
					bg = '#076678',
					bold = true,
				},
			},
		},
	}
}
