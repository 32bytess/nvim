-- easy-dotnet starts the Roslyn LSP itself (client name "easy_dotnet") with its own
-- on_attach, which overrides the global vim.lsp.config("*") one, so hook ours in here.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("dotnet_lsp_attach", { clear = true }),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client.name == "easy_dotnet" then
			require("custom.lsp_attach").on_attach(client, args.buf)
			vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
		end
	end,
})

local netcoredbg = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg"

local function dotnet(fn)
	return function()
		require("easy-dotnet")[fn]()
	end
end

local function dap(fn)
	return function()
		require("dap")[fn]()
	end
end

return {
	{
		"GustavEikaas/easy-dotnet.nvim",
		ft = { "cs", "csproj", "sln", "slnx", "razor", "props" },
		cmd = "Dotnet",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"mfussenegger/nvim-dap",
		},
		keys = {
			{ "<leader>nr", dotnet("run"), desc = ".NET run" },
			{ "<leader>nw", dotnet("watch"), desc = ".NET watch (hot reload)" },
			{ "<leader>nb", dotnet("build_quickfix"), desc = ".NET build (errors to quickfix)" },
			{ "<leader>nt", dotnet("testrunner"), desc = ".NET test runner" },
			{ "<leader>nT", dotnet("test"), desc = ".NET test" },
			{ "<leader>nn", dotnet("new"), desc = ".NET new project" },
			{ "<leader>nf", dotnet("createfile"), desc = ".NET new file from template" },
			{ "<leader>np", dotnet("add_package"), desc = ".NET add NuGet package" },
			{ "<leader>ns", dotnet("secrets"), desc = ".NET user secrets" },
			{ "<leader>nc", dotnet("clean"), desc = ".NET clean" },
			{ "<leader>nR", dotnet("restore"), desc = ".NET restore" },
			{ "<leader>nx", dotnet("stop"), desc = ".NET stop running app" },
			{ "<leader>nd", dotnet("debug"), desc = ".NET debug project" },
			{ "<leader>no", dotnet("outdated"), desc = ".NET show outdated packages" },
			{
				"<leader>ne",
				function()
					require("easy-dotnet.actions.diagnostics").get_workspace_diagnostics("warning")
				end,
				desc = ".NET workspace diagnostics",
			},
		},
		config = function()
			require("easy-dotnet").setup({
				picker = "telescope",
				-- defaults are <leader>r/d/t/p in test files, which clash with <leader>rn, <leader>d*, <leader>t*
				test_runner = {
					auto_start_testrunner = false, -- discover tests on demand (<leader>nt), not on every .cs open
					mappings = {
						run_test_from_buffer = { lhs = "<leader>nu", desc = ".NET run test under cursor" },
						run_all_tests_from_buffer = { lhs = "<leader>nU", desc = ".NET run all tests in file" },
						debug_test_from_buffer = { lhs = "<leader>nD", desc = ".NET debug test under cursor" },
						peek_stack_trace_from_buffer = { lhs = "<leader>nP", desc = ".NET peek test output" },
					},
				},
				lsp = {
					-- default refreshes codelens on every CursorHold (updatetime=250) → constant Roslyn requests
					auto_refresh_codelens = false,
					-- Roslynator + easy-dotnet analyzers add hundreds of analyzers to every diagnostic pass
					roslynator_enabled = false,
					easy_dotnet_analyzer_enabled = false,
					config = {
						settings = {
							["csharp|inlay_hints"] = {
								csharp_enable_inlay_hints_for_implicit_variable_types = true,
								csharp_enable_inlay_hints_for_lambda_parameter_types = true,
								csharp_enable_inlay_hints_for_implicit_object_creation = true,
								dotnet_enable_inlay_hints_for_parameters = true,
								dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
							},
							-- only fetched while codelens is toggled on (<leader>cL)
							["csharp|code_lens"] = {
								dotnet_enable_references_code_lens = true,
								dotnet_enable_tests_code_lens = true,
							},
							-- workspace symbols also search framework / NuGet assemblies
							["csharp|symbol_search"] = { dotnet_search_reference_assemblies = true },
							navigation = { dotnet_navigate_to_decompiled_sources = true },
						},
					},
				},
				debugger = {
					bin_path = vim.fn.executable(netcoredbg) == 1 and netcoredbg or nil,
				},
			})
			if vim.g.colors_name == "wallust" then
				require("theme").apply_plugin_overrides()
			end
		end,
	},
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		dependencies = {
			{ "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
			"theHamsta/nvim-dap-virtual-text",
		},
		keys = {
			{ "<leader>db", dap("toggle_breakpoint"), desc = "Debug: toggle breakpoint" },
			{
				"<leader>dB",
				function()
					require("dap").set_breakpoint(vim.fn.input("Condition: "))
				end,
				desc = "Debug: conditional breakpoint",
			},
			{
				"<leader>dl",
				function()
					require("dap").set_breakpoint(nil, nil, vim.fn.input("Log message: "))
				end,
				desc = "Debug: logpoint",
			},
			{
				"<leader>da",
				function()
					local d = require("dap")
					for _, conf in ipairs(d.configurations.cs or {}) do
						if conf.type == "netcoredbg" and conf.request == "attach" then
							return d.run(conf)
						end
					end
				end,
				desc = "Debug: attach to .NET process",
			},
			{ "<leader>dc", dap("continue"), desc = "Debug: start / continue" },
			{ "<leader>do", dap("step_over"), desc = "Debug: step over" },
			{ "<leader>di", dap("step_into"), desc = "Debug: step into" },
			{ "<leader>dO", dap("step_out"), desc = "Debug: step out" },
			{ "<leader>dC", dap("run_to_cursor"), desc = "Debug: run to cursor" },
			{
				"<leader>dr",
				function()
					require("dap").repl.toggle()
				end,
				desc = "Debug: toggle REPL",
			},
			{ "<leader>dq", dap("terminate"), desc = "Debug: terminate" },
			{
				"<leader>du",
				function()
					require("dapui").toggle()
				end,
				desc = "Debug: toggle UI",
			},
			{
				"<leader>de",
				function()
					require("dapui").eval()
				end,
				mode = { "n", "v" },
				desc = "Debug: evaluate expression",
			},
		},
		config = function()
			local d, dapui = require("dap"), require("dapui")
			dapui.setup()
			require("nvim-dap-virtual-text").setup({ commented = true })

			-- easy-dotnet's adapter only launches through `Dotnet debug`; attaching to an
			-- arbitrary PID needs plain netcoredbg
			d.adapters.netcoredbg = { type = "executable", command = netcoredbg, args = { "--interpreter=vscode" } }
			d.configurations.cs = d.configurations.cs or {}
			table.insert(d.configurations.cs, {
				type = "netcoredbg",
				request = "attach",
				name = "Attach to process",
				processId = require("dap.utils").pick_process,
			})
			d.listeners.after.event_initialized["dapui"] = dapui.open
			d.listeners.before.event_terminated["dapui"] = dapui.close
			d.listeners.before.event_exited["dapui"] = dapui.close

			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejected" })
			vim.fn.sign_define("DapLogPoint", { text = "◉", texthl = "DapLogPoint" })
			vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStopped", linehl = "DapStoppedLine" })
		end,
	},
}
