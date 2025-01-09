-- visually draws vertical lines for code blocks
return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	lazy = true,
	event = "BufEnter",
	opts = {
		indent = {
			tab_char = '▎',
		},
		scope = {
			enabled = true,
			show_start = false,
			show_end = false,
			highlight = "GruvboxRed",
		}
	}
}
