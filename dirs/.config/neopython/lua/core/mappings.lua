local M = {}
local fn = vim.fn
local lsp = vim.lsp
local diagnostic = vim.diagnostic

local feedkey = function(key, mode)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

M.std_mappings = function()
	local wk = require("which-key")
	local tc = require("todo-comments")

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
		{ "<leader>H",  function() vim.diagnostic.hide() end,                    desc = "Hide diagnostics" },
		{ "<leader>b",  group = "Browse" },
		{ "<leader>bd", function() require("browse.devdocs").search() end,       desc = "DevDocs" },
		{ "<leader>bg", function() require("browse.devdocs").input_search() end, desc = "Google" },
		-- opens up the tree
		{ "<leader>e",  neotree_toggle,                                          desc = "Open explorer tree" },
		-- clears search highlighting
		{ "<leader>h",  "<cmd>nohl<cr>",                                         desc = "Hide search highlights" },
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

return M
