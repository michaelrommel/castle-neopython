-- manages crates.io dependencies
return {
	"saecki/crates.nvim",
	lazy = true,
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local crates = require("crates")
		local cm = require("core.mappings")
		crates.setup({
			on_attach = cm.crates_mappings,
			open_programs = { "open", "wslview", "xdg-open" },
			null_ls = {
				enabled = true,
				name = "Crates"
			},
			popup = {
				autofocus = true,
				border = "rounded",
			},
		})
	end
}
