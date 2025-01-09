-- an installer for language servers and debug adapters
return {
	"williamboman/mason.nvim",
	dependencies = {
	},
	lazy = false,
	config = function()
		require('mason').setup({
			ui = {
				border = "rounded"
			}
		})
	end
}
