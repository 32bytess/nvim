vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.o.timeoutlen = 400
vim.o.ttimeoutlen = 10
vim.o.updatetime = 250

vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.signcolumn = "yes"
vim.o.scrolloff = 8
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.winborder = "rounded"

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = "split"

vim.o.undofile = true
vim.o.confirm = true

-- Deferred: clipboard provider detection is slow and not needed at startup
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

vim.diagnostic.config({
	virtual_text = true,
	severity_sort = true,
	float = { border = "rounded", source = true },
})
