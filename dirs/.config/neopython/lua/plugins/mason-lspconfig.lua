-- autoinstaller for language servers' configurations
return {
	"williamboman/mason-lspconfig.nvim",
	lazy = true,
	ft = {
		"sh", "bash", "zsh", "css", "graphql", "html", "json", "json5", "lua",
		"python", "rust", "svelte", "javascript"
	},
	dependencies = {
		"williamboman/mason.nvim",
		-- language server configuration
		"neovim/nvim-lspconfig",
		"hrsh7th/nvim-cmp",
		-- separates the update intervals of lsp from autosaved files/buffers
		"antoinemadec/FixCursorHold.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"aznhe21/actions-preview.nvim",
	},
	config = function()
		require('mason-lspconfig').setup({
			-- A list of servers to automatically install if they're not already installed.
			-- Example: { "rust_analyzer@nightly", "lua_ls" }
			-- This setting has no relation with the `automatic_installation` setting.
			-- The Mason tools, which are not language servers should be in mason-tool-installer
			ensure_installed = {
				"bashls", "cssls", "eslint", "graphql", "html", "jedi_language_server", "jsonls", "lua_ls",
				"rust_analyzer", "svelte", "tailwindcss", "tsserver",
			},

			-- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
			-- This setting has no relation with the `ensure_installed` setting.
			-- Can either be:
			--   - false: Servers are not automatically installed.
			--   - true: All servers set up via lspconfig are automatically installed.
			--   - { exclude: string[] }: All servers set up via lspconfig, except the ones provided in the list, are automatically installed.
			--       Example: automatic_installation = { exclude = { "rust_analyzer", "solargraph" } }
			automatic_installation = {
				exclude = {
					-- "eslint",
				}
			}
		})

		-- set up border around the LspInfo window
		require("lspconfig.ui.windows").default_options.border = 'rounded'

		-- set the default client capabilities from completion module
		--local capabilities = require('cmp_nvim_lsp').default_capabilities()
		local capabilities = vim.tbl_deep_extend("force",
			vim.lsp.protocol.make_client_capabilities(),
			require('cmp_nvim_lsp').default_capabilities()
		)
		-- print(vim.inspect(vim.tbl_keys(capabilities)))

		vim.g.cursorhold_updatetime = 500

		vim.diagnostic.config({
			virtual_text = true,
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = false,
		})

		-- this handler also sets the keymppings
		local on_attach = require("configs.conf_lsp").on_attach

		require("mason-lspconfig").setup_handlers {
			-- The first entry (without a key) will be the default handler
			function(server_name)
				-- print("server_name is " .. server_name)
				require("lspconfig")[server_name].setup({
					on_attach = on_attach,
					capabilities = capabilities,
				})
			end,
			-- Next, you can provide a dedicated handler for specific servers.
			["jsonls"] = function()
				require("lspconfig").jsonls.setup({
					on_attach = on_attach,
					capabilities = capabilities,
					filetypes = { "json", "jsonc", "json5" },
					init_options = {
						provideFormatter = false,
					},
					handlers = {
						["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
							-- jsonls doesn't really support json5
							-- remove some annoying errors
							if string.match(result.uri, "%.json5$", -6) and result.diagnostics ~= nil then
								local idx = 1
								while idx <= #result.diagnostics do
									print("in json5: " .. result.diagnostics[idx].code)
									if result.diagnostics[idx].code == 519 then
										-- "Trailing comma""
										table.remove(result.diagnostics, idx)
									elseif result.diagnostics[idx].code == 521 then
										-- "Comments are not permitted in JSON."
										table.remove(result.diagnostics, idx)
									else
										idx = idx + 1
									end
								end
							end
							vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
						end,
					},
				})
			end,
			["cssls"] = function()
				require("lspconfig").cssls.setup({
					on_attach = on_attach,
					capabilities = capabilities,
					filetypes = { "css" },
					settings = {
						css = {
							-- customData = {
							-- 	"/tmp/tailwind.css-data.json"
							-- },
							lint = {
								unknownAtRules = 'ignore'
							}
						}
					}
				})
			end,
			["bashls"] = function()
				require("lspconfig").bashls.setup({
					on_attach = on_attach,
					capabilities = capabilities,
					filetypes = { "sh", "bash", "zsh" },
				})
			end,
			["eslint"] = function()
				require("lspconfig").eslint.setup({
					on_attach = on_attach,
					capabilities = capabilities,
					root_dir = require("lspconfig/util").root_pattern(
						"package.json", "eslint.config.*"
					),
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
			["rust_analyzer"] = function()
				require("lspconfig").rust_analyzer.setup({
					on_attach = on_attach,
					capabilities = capabilities,
					filetypes = { "rust" },
					root_dir = require("lspconfig/util").root_pattern(
						"Cargo.toml", "rust-project.json"
					),
					single_file_support = true,
					settings = {
						['rust-analyzer'] = {
							diagnostics = {
								enable = true,
							},
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
						}
					}
				})
			end,
			-- ["pyright"] = function()
			-- 	require("lspconfig").pyright.setup({
			-- 		on_attach = on_attach,
			-- 		capabilities = capabilities,
			-- 		filetypes = { "python" },
			-- 		handlers = {
			-- 			["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help),
			-- 		}
			-- 	})
			-- end,
		}
	end
}
