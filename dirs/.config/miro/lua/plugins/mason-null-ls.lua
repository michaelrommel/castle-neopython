-- this ensures that mason autoinstalls the mentioned formatters
return {
	"jay-babu/mason-null-ls.nvim",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" },
	-- ft = { "python", "javascript", "json", "json5", "lua" },
	dependencies = {
		"williamboman/mason.nvim",
		"nvimtools/none-ls.nvim",
	},
	opts = {
		ensure_installed = nil,
		automatic_installation = true,
		automatic_setup = false,
	}
}
