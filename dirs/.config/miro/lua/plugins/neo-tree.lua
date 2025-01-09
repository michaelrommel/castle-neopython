-- explorer style tree on the left
return {
	"nvim-neo-tree/neo-tree.nvim",
	lazy = true,
	branch = "v3.x",
	event = "BufEnter",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
		"s1n7ax/nvim-window-picker",
	},
	opts = {
		popup_border_style = "rounded",
		default_component_configs = {
			name = {
				trailing_slash = true,
			},
			git_status = {
				symbols = {
					-- Change type
					added     = "+", -- or "✚", but this is redundant info if you use git_status_colors on the name
					modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
					deleted   = "✖", -- this can only be used in the git_status source
					renamed   = "󰁕", -- this can only be used in the git_status source
					-- Status type
					untracked = "",
					ignored   = "",
					unstaged  = "󰄱",
					staged    = "",
					conflict  = "",
				}
			}
		},
		window = {
			width = 50,
			mappings = {
				["<c-x>"] = "split_with_window_picker",
				["<c-v>"] = "vsplit_with_window_picker",
			}
		},
		filesystem = {
			filtered_items = {
				visible = false, -- when true, they will just be displayed differently than normal items
				hide_dotfiles = false,
				hide_gitignored = true,
			},
			use_libuv_file_watcher = true,
			follow_current_file = {
				enabled = true,
			},
		},
		buffers = {
			follow_current_file = {
				enabled = true,
			},
		},
	},
}
