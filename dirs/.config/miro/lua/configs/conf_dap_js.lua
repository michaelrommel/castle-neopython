local M = {}

M.setup = function()
	require("dap").adapters["pwa-node"] = {
		type = "server",
		host = "localhost",
		port = "${port}",
		executable = {
			command = "js-debug-adapter",
			args = { "${port}" }
		}
	}
	require("dap").configurations["javascript"] = {
		{
			type = "pwa-node",
			request = "launch",
			name = "Node Launch file",
			program = "${file}",
			cwd = "${workspaceFolder}",
			rootPath = "${workspaceFolder}",
			-- sourceMaps = true,
			-- skipFiles = { '<node_internals>/**' },
			protocol = 'inspector',
			console = 'integratedTerminal',
		},
		{
			type = "pwa-node",
			request = "attach",
			name = "Node Attach",
			-- program = "${file}",
			cwd = "${workspaceFolder}",
			rootPath = "${workspaceFolder}",
			-- sourceMaps = false,
			-- skipFiles = { "<node_internals>/**" },
			protocol = "inspector",
			console = "integratedTerminal",
			address = "127.0.0.1",
		},
	}
	-- require("dap").adapters["codelldb"] = {
	-- 	type = "server",
	-- 	port = "${port}",
	-- 	executable = {
	-- 		command = "codelldb",
	-- 		args = { "--port", "${port}" }
	-- 	}
	-- }
	-- require("dap").configurations["rust"] = {
	-- 	{
	-- 		type = "codelldb",
	-- 		request = "launch",
	-- 		name = "Rust Launch file",
	-- 		program = function()
	-- 			return vim.fn.input("exe: ", vim.fn.getcwd() .. "/target/debug/", "file")
	-- 		end,
	-- 		cwd = "${workspaceFolder}",
	-- 		stopOnEntry = true,
	-- 		showDisassembly = "never",
	-- 	},
	-- }
end

return M
