-- ─── UI / Navigation ────────────────────────────────────────────────────────

-- Clear search highlight; close float window if currently focused
vim.keymap.set("n", "<Esc>", function()
	vim.cmd.nohlsearch()
	local win = vim.api.nvim_get_current_win()
	if vim.api.nvim_win_get_config(win).relative ~= "" then
		vim.api.nvim_win_close(win, false)
	end
end, { desc = "Close float / clear highlight", silent = true })

-- ─── Diagnostics ────────────────────────────────────────────────────────────

vim.keymap.set("n", "<leader>k", vim.diagnostic.open_float, { desc = "Show diagnostic popup", silent = true })

-- ─── Formatting ─────────────────────────────────────────────────────────────

vim.keymap.set({ "n", "v" }, "<leader>gf", function()
	require("custom.smart_format").smart_format()
end, { desc = "Format", silent = true })

-- ─── Terminal ───────────────────────────────────────────────────────────────

local term = require("custom.term_float").new(vim.o.shell)
vim.keymap.set("n", "<leader>tt", term.toggle, { desc = "Toggle terminal float", silent = true })

-- ─── Mobile / ADB ───────────────────────────────────────────────────────────

vim.keymap.set("n", "<leader>aa", function()
	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * 0.5)
	local height = 20
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = "minimal",
		border = "rounded",
		title = " ADB WiFi Pair ",
		title_pos = "center",
	})
	vim.fn.jobstart("adb-wifi", {
		term = true,
		on_exit = function()
			vim.api.nvim_win_close(win, true)
		end,
	})
	vim.cmd("startinsert")
end, { desc = "ADB WiFi QR pair", silent = true })

-- keymaps

vim.keymap.set("i", "jj", "<Esc>")

-- ─── Borrowed from ThePrimeagen (see WIKI.md §11) ───────────────────────────

-- Move the selected lines down / up, re-indenting as they go
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

-- Join lines without the cursor jumping to the join point
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })

-- Keep the cursor centred when scrolling and stepping through search results
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centred)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centred)" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next match (centred)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous match (centred)" })

-- Paste over a selection without losing what you yanked ("greatest remap ever")
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste, keep register" })

-- Replace the word under the cursor everywhere in the file (type the new word, Enter)
vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Substitute word under cursor" }
)

-- Make the current file executable (fresh shell scripts)
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { desc = "chmod +x current file", silent = true })

-- Undo history as a tree (Neovim 0.12 ships this; undofile keeps it across restarts)
vim.cmd.packadd("nvim.undotree")
vim.keymap.set("n", "<leader>u", "<cmd>Undotree<CR>", { desc = "Undo tree" })
