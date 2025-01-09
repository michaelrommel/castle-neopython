-- dim inactive code blocks
return {
	"folke/twilight.nvim",
	lazy = true,
	event = "BufEnter",
	opts = {
		dimming = {
			alpha = 0.7,
		}
	}
}
