local M = {}
local fn = vim.fn
local lsp = vim.lsp
local diagnostic = vim.diagnostic

local feedkey = function(key, mode)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

M.std_mappings = function()
	local wk = require("which-key")
	local ts = require("telescope")
	local tb = require("telescope.builtin")
	local tsc = require("configs.conf_telescope")
	local tc = require("todo-comments")
	local flsh = require("flash")

	local ttc = require("configs.conf_toggleterm")
	local term = require('toggleterm.terminal').Terminal
	local miniterm = term:new(ttc.miniterm_opts)
	local function miniterm_toggle()
		miniterm:toggle()
	end
	local function neotree_toggle()
		local reveal_file = vim.fn.expand('%:p')
		if (reveal_file == '') then
			reveal_file = vim.fn.getcwd()
		else
			local f = io.open(reveal_file, "r")
			if (f) then
				f.close(f)
			else
				reveal_file = vim.fn.getcwd()
			end
		end
		print("neo-tree: reveal_file is " .. reveal_file)
		require('neo-tree.command').execute({
			action = "focus", -- OPTIONAL, this is the default value
			source = "filesystem", -- OPTIONAL, this is the default value
			position = "left", -- OPTIONAL, this is the default value
			reveal_file = reveal_file, -- path to file or folder to reveal
			reveal_force_cwd = true, -- change cwd without asking if needed
		})
	end

	-- remove the default mapping of Y to y$
	vim.keymap.del('n', 'Y')

	wk.add({
		{ "gb", "<plug>(comment_toggle_blockwise_visual)", desc = "Comment toggle blockwise (visual)", mode = "v" },
		{ "gc", "<plug>(comment_toggle_linewise_visual)",  desc = "Comment toggle linewise (visual)",  mode = "v" },
	})
	wk.add({
		-- moves the cursor left and right in insert mode
		{ "<C-h>", "<Left>",  desc = "Move 1 char left",  mode = { "i", "v" } },
		{ "<C-l>", "<Right>", desc = "Move 1 char right", mode = { "i", "v" } },
		-- ['kj'] = { "<Esc>", "Alternative Escape" },
	})
	wk.add({
		{ "<C-c>", function() miniterm_toggle() end,   desc = "Toggle Mini Terminal" },
		-- jumps to splits
		{ "<C-h>", "<C-w>h",                           desc = "Left split" },
		{ "<C-j>", "<C-w>j",                           desc = "Lower split" },
		{ "<C-k>", "<C-w>k",                           desc = "Upper split" },
		{ "<C-l>", "<C-w>l",                           desc = "Right split" },
		{ "[t",    function() tc.jump_prev() end,      desc = "Previous TODO" },
		{ "]t",    function() tc.jump_next() end,      desc = "Next TODO" },
		{ "gb",    "<plug>(comment_toggle_blockwise)", desc = "Comment toggle blockwise" },
		{ "gc",    "<plug>(comment_toggle_linewise)",  desc = "Comment toggle linewise" },
	})
	wk.add({
		-- ['/'] = { function() flsh.jump() end, "Search with flash" },
		-- x = visual mode only, o = operator pending mode
		{ "S", function() flsh.treesitter() end, desc = "Search Treesitter tags with flash", mode = { "n", "x" } },
	})
	wk.add({
		-- ['kj'] = { "<C-\\><C-n>", "Put terminal in Normal mode" },
		{ "<C-q>", "<C-\\><C-n>", desc = "Put terminal in Normal mode", mode = "t" },
	})
	wk.add({
		mode = { "v" },
		{ "<leader>s",  group = "Silicon" },
		{ "<leader>sc", function() require("nvim-silicon").clip() end,  desc = "Copy code screenshot to clipboard" },
		{ "<leader>sf", function() require("nvim-silicon").file() end,  desc = "Save code screenshot as file" },
		{ "<leader>ss", function() require("nvim-silicon").shoot() end, desc = "Create code screenshot" },
	})
	wk.add({
		{ "<leader>H",  function() vim.diagnostic.hide() end,                    desc = "Hide diagnostics" },
		{ "<leader>b",  group = "Browse" },
		{ "<leader>bd", function() require("browse.devdocs").search() end,       desc = "DevDocs" },
		{ "<leader>bg", function() require("browse.devdocs").input_search() end, desc = "Google" },
		-- opens up the tree
		{ "<leader>e",  neotree_toggle,                                          desc = "Open explorer tree" },
		-- ['e'] = { function() require("nvim-tree.api").tree.focus() end, "Open explorer tree" },
		-- find functions with telescope
		{ "<leader>f",  group = "Find" },
		{ "<leader>fb", function() tb.buffers() end,                             desc = "Find buffers" },
		{ "<leader>fc", function() ts.extensions.neoclip.default() end,          desc = "Find clipboard" },
		{ "<leader>fd", function() tb.diagnostics() end,                         desc = "Find diagnostics" },
		{
			"<leader>ff",
			function()
				tb.find_files({
					find_command =
					{ 'rg', '--files', '--hidden', '-g', '!.git' }
				})
			end,
			desc = "Find files"
		},
		{ "<leader>fg", function() tb.live_grep() end,                         desc = "Live grep" },
		{ "<leader>fp", function() tsc.find_files_from_project_git_root() end, desc = "Find files in project" },
		-- clears search highlighting
		{ "<leader>h",  "<cmd>nohl<cr>",                                       desc = "Hide search highlights" },
		{ "<leader>s",  group = "Silicon" },
		{ "<leader>sc", function() require("nvim-silicon").shoot() end,        desc = "Put code screenshot to clipboard" },
		{ "<leader>sf", function() require("nvim-silicon").file() end,         desc = "Put code screenshot to file" },
		{ "<leader>ss", function() require("nvim-silicon").clip() end,         desc = "Create code screenshot" },
		-- zen mode
		{ "<leader>z",  function() require("zen-mode").toggle() end,           desc = "Toggle zen mode" },
	})
end

M.gitsigns_mappings = function(bufnr)
	local wk = require("which-key")
	local gs = package.loaded.gitsigns
	wk.add({
		{ "<leader>g",   group = "Git" },
		{ "<leader>gD",  function() gs.diffthis('~') end,               buffer = bufnr, desc = "Diff ~ (last commit)" },
		{ "<leader>gR",  gs.reset_buffer,                               buffer = bufnr, desc = "Reset buffer" },
		{ "<leader>gS",  gs.stage_buffer,                               buffer = bufnr, desc = "Stage buffer" },
		{ "<leader>gb",  function() gs.blame_line({ full = true }) end, buffer = bufnr, desc = "Blame line" },
		{ "<leader>gd",  gs.diffthis,                                   buffer = bufnr, desc = "Diff" },
		{ "<leader>gp",  gs.preview_hunk,                               buffer = bufnr, desc = "Preview hunk" },
		{ "<leader>gr",  gs.reset_hunk,                                 buffer = bufnr, desc = "Reset hunk" },
		{ "<leader>gs",  gs.stage_hunk,                                 buffer = bufnr, desc = "Stage hunk" },
		{ "<leader>gt",  group = "Toggles" },
		{ "<leader>gtb", gs.toggle_current_line_blame,                  buffer = bufnr, desc = "Toggle blame" },
		{ "<leader>gtd", gs.toggle_deleted,                             buffer = bufnr, desc = "Toggle deleted" },
		{ "<leader>gu",  gs.undo_stage_hunk,                            buffer = bufnr, desc = "Undo stage hunk" },
	})
	wk.add({
		{ "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, buffer = bufnr, desc = "Reset hunk", mode = "v" },
		{ "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, buffer = bufnr, desc = "Stage hunk", mode = "v" },
	})
	wk.add({
		{
			"[h",
			function()
				if vim.wo.diff then return '[c' end
				vim.schedule(function() gs.prev_hunk() end)
				return '<Ignore>'
			end,
			buffer = bufnr,
			desc = "Previous hunk",
			expr = true,
			replace_keycodes = false
		},
		{
			"]h",
			function()
				if vim.wo.diff then return ']c' end
				vim.schedule(function() gs.next_hunk() end)
				return '<Ignore>'
			end,
			buffer = bufnr,
			desc = "Next hunk",
			expr = true,
			replace_keycodes = false
		},
	})
	wk.add({
		{ "ih", buffer = bufnr, desc = ":<C-U>Gitsigns select_hunk<cr>", mode = { "o", "x" } },
	})
end

M.cmp_mappings = function()
	local cmp = require("cmp")
	local has_words_before = function()
		unpack = unpack or table.unpack
		local line, col = unpack(vim.api.nvim_win_get_cursor(0))
		return col ~= 0 and
			vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
	end
	return {
		-- scroll the documentation, if an entry provides it
		['<C-y>'] = cmp.mapping.scroll_docs(-4), -- Up
		['<C-e>'] = cmp.mapping.scroll_docs(4), -- Down
		-- opens the menu if it does not automatically appear
		['<C-Space>'] = cmp.mapping(function()
			if cmp.visible() then
				cmp.abort()
			else
				-- print("complete()")
				cmp.complete()
			end
		end, { 's', 'i' }),
		-- confirm the current selection and close float
		['<CR>'] = cmp.mapping.confirm {
			-- replace rest of the word if in the middle
			behavior = cmp.ConfirmBehavior.Replace,
			-- do not autoselect the first item on <CR>
			select = false,
		},
		-- allow navigation inside the float with j and k
		['j'] = cmp.mapping(function(fallback)
			-- if cmp.visible() and cmp.get_active_entry() then
			-- actually enter the float also on j
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { 'i', 's' }),
		['k'] = cmp.mapping(function(fallback)
			if cmp.visible() and cmp.get_active_entry() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { 'i', 's' }),
		-- inside float, navigate up/down, also jump in snippets
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif fn["vsnip#available"](1) == 1 then
				feedkey("<Plug>(vsnip-expand-or-jump)", "")
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { 'i', 's' }),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif fn["vsnip#available"](-1) == 1 then
				feedkey("<Plug>(vsnip-jump-prev)", "")
			else
				fallback()
			end
		end, { 'i', 's' }),
	}
end

M.dap_mappings = function()
	-- the debug adapter protocol can open modal floating windows, this mapping allows
	-- the Esc key to close them
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "dap-float",
		callback = function()
			vim.keymap.set('n', '<Esc>', "<cmd>close!<CR>", { buffer = true, noremap = true, silent = true })
		end
	})
	local wk = require("which-key")
	-- standard key mappings
	wk.add({
		-- step into the function: mnemonic debug in
		{ "<C-S-i>", function() require('dap').step_into() end, desc = "Step Into" },
		-- step over the function: mnemonic debug jump over
		{ "<C-S-j>", function() require('dap').step_over() end, desc = "Step Over" },
		-- terminate debugging session: mnemonic kill debugger
		{ "<C-S-k>", function() require('dap').terminate() end, desc = "Kill/Stop Debugger" },
		-- step out to the calling function: mnemonic out
		{ "<C-S-o>", function() require('dap').step_out() end,  desc = "Step Out" },
		-- start debugging: mnemonic play
		{ "<C-S-p>", function() require('dap').continue() end,  desc = "Play" },
	})
	-- document the leader key mappings
	wk.add({
		{ "<Leader>d",  group = "Debug" },
		-- set a breakpoint
		{ "<Leader>dB", function() require('dap').set_breakpoint() end,    desc = "Breakpoint Set" },
		-- re-start the debug session: mnemonic debug again
		{ "<Leader>da", function() require('dap').run_last() end,          desc = "Again the last run" },
		-- toggle a breakpoint: mnemonic debug breakpoint
		{ "<Leader>db", function() require('dap').toggle_breakpoint() end, desc = "Breakpoint Toggle" },
		-- continue the debugging: mnemonic debug continue
		{ "<Leader>dc", function() require('dap').continue() end,          desc = "Continue" },
		-- show the stack frames, can navigate around the call stack: mnemonic debug frames
		{
			"<Leader>df",
			function()
				local widgets = require('dap.ui.widgets')
				widgets.centered_float(widgets.frames)
			end,
			desc = "Frames on the stack"
		},
		-- show variable or function status inspector: mnemonic debug hover
		{ "<Leader>dh", function() require('dap.ui.widgets').hover() end,                                        desc = "Hover" },
		-- set a log point: mnemonic debug logmessage
		{ "<Leader>dl", function() require('dap').set_breakpoint(nil, nil, fn.input('Log point message: ')) end, desc = "Log Point" },
		-- open a repl, switch to insert mode for a prompt: mnemonic debug open
		{ "<Leader>do", function() require('dap').repl.open() end,                                               desc = "Open REPL" },
		-- show variables or function status inspector in a separate split: mnemonic debug preview
		{ "<Leader>dp", function() require('dap.ui.widgets').preview() end,                                      desc = "Preview" },
		-- start the debugging: mnemonic debug run
		{
			"<Leader>dr",
			function()
				if vim.bo.filetype == "javascript" then
					local addr = fn.input("Host: ", "127.0.0.1")
					require("dap").configurations["javascript"][2]["address"] = addr
				end
				require('dap').continue()
			end,
			desc = "Run"
		},
		-- show the variables in all scopes: mnemonic debug scopes
		{
			"<Leader>ds",
			function()
				local widgets = require('dap.ui.widgets')
				widgets.centered_float(widgets.scopes)
			end,
			desc = "Scopes"
		},
		-- show the whole debugging ui: mnemonic debug ui
		{
			"<Leader>du",
			function()
				-- require('dapui').setup()
				require('dapui').toggle()
			end,
			desc = "UI display"
		},
	})
end

M.lsp_mappings = function(bufnr)
	local wk = require("which-key")
	local function show_documentation()
		local filetype = vim.bo.filetype
		if vim.tbl_contains({ 'vim', 'help' }, filetype) then
			vim.cmd('h ' .. vim.fn.expand('<cword>'))
		elseif vim.tbl_contains({ 'man' }, filetype) then
			vim.cmd('Man ' .. vim.fn.expand('<cword>'))
		elseif vim.fn.expand('%:t') == 'Cargo.toml' and require('crates').popup_available() then
			require('crates').show_popup()
		else
			vim.lsp.buf.hover()
		end
	end
	wk.add({
		-- ['K'] = { lsp.buf.hover, "Show LSP symbol info" },
		{ "K",   show_documentation,     buffer = bufnr, desc = "Show LSP symbol info / docs", remap = false },
		{ "[d]", diagnostic.goto_prev,   buffer = bufnr, desc = "Goto previous diagnostics",   remap = false },
		{ "]d",  diagnostic.goto_next,   buffer = bufnr, desc = "Goto next diagnostics",       remap = false },
		{ "g",   group = "Goto",         remap = false },
		{ "gD",  lsp.buf.declaration,    buffer = bufnr, desc = "Goto declaration",            remap = false },
		{ "gd",  lsp.buf.definition,     buffer = bufnr, desc = "Goto definition",             remap = false },
		{ "gi",  lsp.buf.implementation, buffer = bufnr, desc = "Goto implementation",         remap = false },
		{ "gr",  lsp.buf.references,     buffer = bufnr, desc = "Goto references",             remap = false },
		{ "gs",  lsp.buf.signature_help, buffer = bufnr, desc = "Show LSP function signature", remap = false },
	})
	wk.add({
		{ "<leader>D",  diagnostic.open_float,                                    buffer = bufnr, desc = "Open diagnostics float",        remap = false },
		{ "<leader>a",  function() require('actions-preview').code_actions() end, buffer = bufnr, desc = "Code actions preview",          remap = false },
		{ "<leader>q",  diagnostic.setloclist,                                    buffer = bufnr, desc = "Open quickfix window",          remap = false },
		{ "<leader>r",  group = "Rename",                                         remap = false },
		{ "<leader>rn", lsp.buf.rename,                                           buffer = bufnr, desc = "Rename all symbol occurrences", remap = false },
		{ "<leader>t",  lsp.buf.type_definition,                                  buffer = bufnr, desc = "Goto type definition",          remap = false },
		{ "<leader>w",  group = "Workspace",                                      remap = false },
		{ "<leader>wa", lsp.buf.add_workspace_folder,                             buffer = bufnr, desc = "Add workspace folder",          remap = false },
		{
			"<leader>wl",
			function()
				print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
			end,
			buffer = bufnr,
			desc = "List all workspaces",
			remap = false
		},
		{ "<leader>wr", lsp.buf.remove_workspace_folder, buffer = bufnr, desc = "Remove workspace folder", remap = false },
	})
end

M.crates_mappings = function(bufnr)
	local wk = require("which-key")
	local crates = require("crates")
	wk.add({
		{ "<leader>c",  group = "Crates",                          remap = false },
		{ "<leader>cA", crates.upgrade_all_crates,                 buffer = bufnr, desc = "Crates.io",          remap = false },
		{ "<leader>cC", crates.open_crates_io,                     buffer = bufnr, desc = "Crates.io",          remap = false },
		{ "<leader>cD", crates.open_documentation,                 buffer = bufnr, desc = "Documentation",      remap = false },
		{ "<leader>cE", crates.extract_crate_into_table,           buffer = bufnr, desc = "Extract into table", remap = false },
		{ "<leader>cH", crates.open_homepage,                      buffer = bufnr, desc = "Homepage",           remap = false },
		{ "<leader>cR", crates.open_repository,                    buffer = bufnr, desc = "Repository",         remap = false },
		{ "<leader>cU", crates.upgrade_crate,                      buffer = bufnr, desc = "Upgrade crate",      remap = false },
		{ "<leader>ca", crates.update_all_crates,                  buffer = bufnr, desc = "Update all crates",  remap = false },
		{ "<leader>cd", crates.show_dependencies_popup,            buffer = bufnr, desc = "Dependencies",       remap = false },
		{ "<leader>ce", crates.expand_plain_crate_to_inline_table, buffer = bufnr, desc = "Expand to table",    remap = false },
		{ "<leader>cf", crates.show_features_popup,                buffer = bufnr, desc = "Features",           remap = false },
		{ "<leader>cr", crates.reload,                             buffer = bufnr, desc = "Reload",             remap = false },
		{ "<leader>ct", crates.toggle,                             buffer = bufnr, desc = "Toggle",             remap = false },
		{ "<leader>cu", crates.update_crate,                       buffer = bufnr, desc = "Update crate",       remap = false },
		{ "<leader>cv", crates.show_versions_popup,                buffer = bufnr, desc = "Versions",           remap = false },
	})
end

return M
