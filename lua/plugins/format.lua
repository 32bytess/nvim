local function too_large(bufnr)
	local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(bufnr))
	return size > 100 * 1024 or size == -2
end

return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "black" },
			sh = { "shfmt" },
			bash = { "shfmt" },
			dart = { "dart_format" },
			go = { "goimports", "gofmt" },
			sql = { "sql_formatter" },
		},
		formatters = {
			-- postgresql dialect: the default "sql" one rejects $1-style placeholders (sqlc queries)
			sql_formatter = { prepend_args = { "-l", "postgresql" } },
		},
		format_on_save = function(bufnr)
			if too_large(bufnr) then
				return nil
			end
			-- C# has no conform formatter on purpose: Roslyn (easy_dotnet) formats it like Visual Studio
			return { timeout_ms = 1000, lsp_format = "fallback" }
		end,
	},
}
