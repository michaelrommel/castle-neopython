-- automatic session handling, storing sessions in a dir under .local/share/miro/sessions
return {
	"rmagatti/auto-session",
	lazy = true,
	event = "BufEnter",
	config = function()
		require("auto-session").setup({
			log_level = "error",
			auto_session_suppress_dirs = { "~/", "/" },
			auto_session_enabled = true,
			auto_session_create_enabled = true,
			pre_save_cmds = { "tabdo Neotree action=close" },
			bypass_session_save_file_types = { "gitcommit", "neo-tree" }
		})
	end
}
