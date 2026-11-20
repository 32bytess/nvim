local M = {}

local function picker(name)
	return function()
		require("telescope.builtin")[name]()
	end
end

-- Neovim 0.11+ already provides grr (references), gri (implementation),
-- grn (rename), gra (code action) and K (hover) for LSP buffers.
M.on_attach = function(_, buf)
	local opts = { buffer = buf }
	local map = function(key, fn, desc)
		vim.keymap.set("n", key, fn, vim.tbl_extend("force", opts, { desc = desc }))
	end
	map("gd", vim.lsp.buf.definition, "Go to definition")
	map("gD", vim.lsp.buf.declaration, "Go to declaration")
	map("K", vim.lsp.buf.hover, "Hover docs")
	map("<leader>ca", vim.lsp.buf.code_action, "Code action")
	map("<leader>rn", vim.lsp.buf.rename, "Rename")
	map("[d", function()
		vim.diagnostic.jump({ count = -1, float = true })
	end, "Prev diagnostic")
	map("]d", function()
		vim.diagnostic.jump({ count = 1, float = true })
	end, "Next diagnostic")

	-- Telescope pickers ("gR", not "gr": that would delay the built-in gr* maps)
	map("gR", picker("lsp_references"), "References (Telescope)")
	map("gI", picker("lsp_implementations"), "Implementations (Telescope)")
	map("gy", picker("lsp_type_definitions"), "Type definitions (Telescope)")
	map("<leader>fs", picker("lsp_document_symbols"), "Telescope document symbols")
	map("<leader>fS", picker("lsp_dynamic_workspace_symbols"), "Telescope workspace symbols")
	map("<leader>fc", picker("lsp_incoming_calls"), "Telescope incoming calls")

	map("<leader>ci", function()
		vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
	end, "Toggle inlay hints")
	map("<leader>cl", vim.lsp.codelens.run, "Run codelens")
	-- off by default: refreshing codelens on every edit means constant server requests
	map("<leader>cL", function()
		vim.lsp.codelens.enable(not vim.lsp.codelens.is_enabled({ bufnr = buf }), { bufnr = buf })
	end, "Toggle codelens")
end

return M
