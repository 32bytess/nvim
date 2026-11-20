vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			workspace = { checkThirdParty = false },
			diagnostics = { globals = { "vim", "require" } },
		},
	},
})

vim.lsp.config("bashls", {
	cmd = { "bash-language-server", "start" },
	filetypes = { "bash", "sh" },
	root_markers = { ".git" },
})

vim.lsp.config("pylsp", {
	cmd = { "pylsp" },
	filetypes = { "python" },
	root_markers = { ".git" },
})

vim.lsp.config("gopls", {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { "go.work", "go.mod", ".git" },
	-- Neovim does not advertise file watching on Linux, so gopls never sees files
	-- written outside the editor (sqlc generate, go generate) until a restart.
	capabilities = {
		workspace = {
			didChangeWatchedFiles = { dynamicRegistration = true },
		},
	},
	settings = {
		gopls = {
			completeUnimported = true,
			staticcheck = true,
			analyses = { unusedparams = true, shadow = true },
			hints = { parameterNames = true, assignVariableTypes = true },
		},
	},
})

vim.lsp.config("*", {
	on_attach = require("custom.lsp_attach").on_attach,
})

vim.lsp.enable("lua_ls")
vim.lsp.enable("bashls")
vim.lsp.enable("pylsp")
vim.lsp.enable("gopls")

return {
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		event = "VeryLazy",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "stylua", "bashls", "pylsp", "gopls" },
			})
		end,
	},
	-- none lsp (formatters,linters)
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = { "shfmt", "black", "flake8", "shellcheck", "netcoredbg", "goimports", "sql-formatter" },
		},
	},
	{
		"saghen/blink.cmp",
		dependencies = {
			"saghen/blink.lib",
			"rafamadriz/friendly-snippets",
		},
		build = function()
			require("blink.cmp").build():wait(60000)
		end,
		opts = {
			keymap = {
				preset = "none",
				["<C-j>"] = { "select_next", "fallback" },
				["<C-k>"] = { "select_prev", "fallback" },
				["<CR>"] = { "accept", "fallback" },
				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
			},
			completion = { documentation = { auto_show = false } },
			sources = { default = { "lsp", "path", "snippets", "buffer" } },
			fuzzy = { implementation = "prefer_rust" },
		},
	},
}
