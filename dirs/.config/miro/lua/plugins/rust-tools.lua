-- rust lsp and debugging tooling
return {
	"simrat39/rust-tools.nvim",
	lazy = false,
	dependencies = {
		"neovim/nvim-lspconfig",
		"mfussenegger/nvim-dap",
	},
	config = function()
		local rt = require("rust-tools")
		local cdp = require("configs.conf_dap_rust")

		local opts = {
			tools = {
				hover_actions = {
					auto_focus = true,
				},
			},
			dap = {
				adapter = cdp.get_codelldb_adapter()
			},
			server = {
				on_attach = function(_, bufnr)
					-- Hover actions
					vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
					-- Code action groups
					--vim.keymap.set("n", "<Space>a", rt.code_action_group.code_action_group, { buffer = bufnr })
				end
			},
			settings = {
				-- moved over from mason-lspconfig to avoid conflicts
				['rust-analyzer'] = {
					cargo = {
						allFeatures = true,
						buildScripts = {
							enable = true,
						}
					},
					checkOnSave = {
						allFeatures = true,
						overrideCommand = {
							'cargo', 'clippy', '--workspace', '--message-format=json',
							'--all-targets', '--all-features'
						}
					},
					completion = {
						autoimport = {
							enable = true
						}
					}
				}
			},
		}
		rt.setup(opts)
	end
}
