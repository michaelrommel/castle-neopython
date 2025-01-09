-- this extends the builtin treesitter and autoloads additional language
-- grammars when a buffer is opened
return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	event = { "BufEnter" },
	build = function()
		require("nvim-treesitter.install").update({ with_sync = true })
	end,
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
			-- Install parsers synchronously (only applied to `ensure_installed`)
			sync_install = true,
			auto_install = true,
			highlight = {
				enable = true,
			}
		})
	end
}
