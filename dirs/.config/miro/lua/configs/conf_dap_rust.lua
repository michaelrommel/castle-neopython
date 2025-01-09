local M = {}

local dap = require("dap")
local mr = require("mason-registry")
local utils = require("core.utils")

-- this gets used in nvim-dap and rust-tools
M.get_codelldb_adapter = function()
	local command = nil
	local args = nil
	local code = nil
	local ok, codelldb = pcall(mr.get_package, "codelldb")

	if ok then
		code = codelldb:get_install_path()
	else
		vim.notify_once("delaying rust dap init until mason codelldb is available")
		return {}
	end

	if utils.is_mac then
		-- print(string.format("mac: %s", code))
		command = code .. "/extension/adapter/codelldb"
		args = {
			"--liblldb", code .. "/extension/lldb/lib/liblldb.dylib",
			"--settings", '{"showDisassembly": "never", "sourceLanguages": ["rust"]}'
		}
	else
		-- print(string.format("linux: %s", code))
		command = code .. "/extension/adapter/codelldb"
		args = {
			"--liblldb", code .. "/extension/lldb/lib/liblldb.so",
			"--settings", '{"showDisassembly": "never", "sourceLanguages": ["rust"]}'
		}
	end
	-- local host = "127.0.0.1"
	-- local port = 13333
	return {
		type = "server",
		port = "${port}",
		executable = {
			command = command,
			args = vim.list_extend({ "--port", "${port}" }, args)
		}
	}
end

M.setup = function()
	dap.adapters.codelldb = M.get_codelldb_adapter()
	dap.configurations.rust = {
		{
			type = "codelldb",
			request = "launch",
			name = "Debug",
			program = function()
				return vim.fn.input("exe: ", vim.fn.getcwd() .. "/target/debug/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			showDisassembly = "never",
		},
	}
end

return M
