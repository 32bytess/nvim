return {
	{
		"malewicz1337/oil-git.nvim",
		dependencies = { "stevearc/oil.nvim" },
		config = function()
			require("oil-git").setup({
				debounce_ms = 200,
				show_file_highlights = true,
				show_directory_highlights = true,
				show_file_symbols = true,
				show_directory_symbols = true,
				show_ignored_files = true,
				show_ignored_directories = false,
				symbols = {
					file = {
						added = "+",
						modified = "~",
						renamed = "->",
						deleted = "D",
						copied = "C",
						conflict = "!",
						untracked = "?",
						ignored = "o",
					},
					directory = {
						added = "*",
						modified = "*",
						renamed = "*",
						deleted = "*",
						copied = "*",
						conflict = "!",
						untracked = "*",
						ignored = "o",
					},
				},
			})
		end,
	},
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		lazy = false,
		config = function()
			local oil = require("oil")

			oil.setup({
				default_file_explorer = true,
				delete_to_trash = true,
				skip_confirm_for_simple_edits = true,
				lsp_file_methods = {
					enabled = true,
					timeout_ms = 1000,
					autosave_changes = false,
				},
				view_options = {
					show_hidden = true,
				},
				float = {
					padding = 2,
					border = "rounded",
				},
			})
			vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Oil" })
			vim.keymap.set("n", "<leader>e", oil.toggle_float, { desc = "Float" })

			local stdin_read = false
			local open_group = vim.api.nvim_create_augroup("oil_open_on_empty", { clear = true })
			vim.api.nvim_create_autocmd("StdinReadPre", {
				group = open_group,
				callback = function()
					stdin_read = true
				end,
			})
			vim.api.nvim_create_autocmd("VimEnter", {
				group = open_group,
				nested = true,
				callback = function()
					if
						stdin_read
						or vim.fn.argc() ~= 0
						or #vim.api.nvim_list_uis() == 0
						or vim.api.nvim_buf_get_name(0) ~= ""
						or vim.bo.buftype ~= ""
						or vim.bo.filetype ~= ""
					then
						return
					end
					if vim.api.nvim_buf_line_count(0) > 1 or vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] ~= "" then
						return
					end
					oil.open()
				end,
			})
		end,
	},
}
