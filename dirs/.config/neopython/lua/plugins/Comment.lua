-- small commeing/uncommenting plugin
return {
	"numToStr/Comment.nvim",
	lazy = true,
	event = "BufEnter",
	opts = {
		mappings = {
			-- we set up keymaps ourselves
			basic = false,
			extra = false,
		}
	}
}
