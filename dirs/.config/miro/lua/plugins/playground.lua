-- this enables treesitter tree queries
return {
	"nvim-treesitter/playground",
	lazy = true,
	event = "BufEnter",
	config = function()
		require("nvim-treesitter.configs").setup({
			playground = {
				enable = true,
			}
		})
	end
}
