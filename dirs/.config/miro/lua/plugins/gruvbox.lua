-- the colour scheme
return {
	"michaelrommel/gruvbox.nvim",
	-- dir = "/Volumes/Samsung/software/michael/gruvbox.nvim",
	name = "gruvbox.nvim",
	lazy = false,
	priority = 1000, -- make sure to load this before all the other start plugins
	config = function()
		require("configs.conf_gruvbox").setup()
	end,
}
