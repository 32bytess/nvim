local parsers = {
	"lua",
	"vim",
	"vimdoc",
	"query",
	"regex",
	"yaml",
	"toml",
	"json",
	"markdown",
	"markdown_inline",
	"bash",
	"python",
	"go",
	"dart",
	"c_sharp",
	"xml",
	"diff",
	"gitcommit",
	"http",
}

local function is_large(bufnr)
	if vim.api.nvim_buf_get_name(bufnr):match("%.ipynb$") then
		return false
	end
	local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(bufnr))
	return size > 100 * 1024 or size == -2
end

local function start(bufnr, lang)
	if not pcall(vim.treesitter.start, bufnr, lang) then
		return
	end
	if lang ~= "json" then
		vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end
end

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")
		ts.install(parsers)

		local available = nil
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter", { clear = true }),
			callback = function(args)
				local bufnr = args.buf
				if vim.bo[bufnr].buftype ~= "" or is_large(bufnr) then
					return
				end
				local lang = vim.treesitter.language.get_lang(args.match)
				if not lang then
					return
				end
				if vim.list_contains(ts.get_installed("parsers"), lang) then
					start(bufnr, lang)
					return
				end
				-- auto_install replacement: fetch parsers we don't have yet
				available = available or ts.get_available()
				if vim.list_contains(available, lang) then
					ts.install(lang):await(function()
						vim.schedule(function()
							if vim.api.nvim_buf_is_valid(bufnr) then
								start(bufnr, lang)
							end
						end)
					end)
				end
			end,
		})
	end,
}
