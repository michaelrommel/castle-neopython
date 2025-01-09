-- autoinstaller for language servers' configurations
return {
	"williamboman/mason-lspconfig.nvim",
	lazy = true,
	ft = { "sh", "bash", "zsh", "css", "graphql", "html", "json", "json5", "lua", "python", "rust", "svelte",
		"javascript" },
	dependencies = {
		"williamboman/mason.nvim",
		-- language server configuration
		"neovim/nvim-lspconfig",
		"hrsh7th/nvim-cmp",
		-- separates the update intervals of lsp from autosaved files/buffers
		"antoinemadec/FixCursorHold.nvim"
	},
	config = function()
		require('mason-lspconfig').setup({
			ensure_installed = { "bashls", "cssls", "graphql", "html", "lua_ls", "pyright",
				"ruff_lsp", "rust_analyzer", "svelte", "tailwindcss", "tsserver" },
			-- automatic_installation = true,
		})

		-- inject default capabilities from completion module
		local capabilities = require('cmp_nvim_lsp').default_capabilities()
		-- print(vim.inspect(vim.tbl_keys(capabilities)))

		vim.g.cursorhold_updatetime = 500

		vim.diagnostic.config({
			virtual_text = true,
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = false,
		})

		local on_attach = require("configs.conf_lsp").on_attach

		require("mason-lspconfig").setup_handlers {
			-- The first entry (without a key) will be the default handler
			function(server_name)
				require("lspconfig")[server_name].setup({
					on_attach = on_attach,
					capabilities = capabilities,
				})
			end,
			-- Next, you can provide a dedicated handler for specific servers.
			["bashls"] = function()
				require("lspconfig").bashls.setup({
					on_attach = on_attach,
					capabilities = capabilities,
					filetypes = { "sh", "bash", "zsh" },
				})
			end,
			["lua_ls"] = function()
				require("lspconfig").lua_ls.setup({
					on_attach = on_attach,
					capabilities = capabilities,
					filetypes = { "lua" },
					settings = {
						Lua = {
							diagnostics = {
								-- Get the language server to recognize the `vim` global
								globals = { 'vim' },
							},
							telemetry = {
								enable = false,
							},
						}
					}
				})
			end,
			["pyright"] = function()
				require("lspconfig").pyright.setup({
					on_attach = on_attach,
					capabilities = capabilities,
					filetypes = { "python" },
					handlers = {
						["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help),
					}
				})
			end,
			-- moved to rust-tools, since it would conflict
			["rust_analyzer"] = function() end
			-- ["rust_analyzer"] = function()
			-- 	require("lspconfig").rust_analyzer.setup({
			-- 		on_attach = on_attach,
			-- 		capabilities = capabilities,
			-- 		filetypes = { "rust" },
			-- 		root_dir = require("lspconfig/util").root_pattern("Cargo.toml"),
			-- 		settings = {
			-- 			['rust-analyzer'] = {
			-- 				cargo = {
			-- 					allFeatures = true,
			-- 					buildScripts = {
			-- 						enable = true,
			-- 					}
			-- 				},
			-- 				checkOnSave = {
			-- 					allFeatures = true,
			-- 					overrideCommand = {
			-- 						'cargo', 'clippy', '--workspace', '--message-format=json',
			-- 						'--all-targets', '--all-features'
			-- 					}
			-- 				},
			-- 			}
			-- 		}
			-- 	})
			-- end,
		}
	end
}
