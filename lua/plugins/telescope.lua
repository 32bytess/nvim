local function builtin(name, opts)
	return function()
		require("telescope.builtin")[name](opts)
	end
end

local function gh(name, opts)
	return function()
		require("telescope").extensions.gh[name](opts)
	end
end

return {
	{
		"nvim-telescope/telescope.nvim",
		version = "*",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-telescope/telescope-github.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
		},
		init = function()
			-- Load telescope (and ui-select) on the first vim.ui.select call
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.select = function(...)
				require("lazy").load({ plugins = { "telescope.nvim" } })
				return vim.ui.select(...)
			end
		end,
		keys = {
			{
				"<leader>ff",
				builtin("find_files", { find_command = { "fd", "--type", "f", "--hidden", "--follow" } }),
				desc = "Telescope find files",
			},
			{
				"<leader>fg",
				builtin("live_grep", { additional_args = { "--hidden" } }),
				desc = "Telescope live grep",
			},
			{
				"<leader>fd",
				builtin("find_files", { find_command = { "fd", "--type", "d", "--hidden", "--exclude", ".git" } }),
				desc = "Telescope find dirs",
			},
			{ "<leader>fb", builtin("buffers"), desc = "Telescope buffers" },
			{
				"<leader>fw",
				function()
					require("telescope.builtin").grep_string({ search = vim.fn.expand("<cword>") })
				end,
				desc = "Telescope grep word under cursor",
			},
			{
				"<leader>fW",
				function()
					require("telescope.builtin").grep_string({ search = vim.fn.expand("<cWORD>") })
				end,
				desc = "Telescope grep WORD under cursor",
			},
			{ "<leader>fH", builtin("help_tags"), desc = "Telescope help tags" },
			{
				"<leader>fe",
				builtin("diagnostics", { severity = { "error", "warn" } }),
				desc = "Telescope diagnostics (Errors & Warnings)",
			},

			-- git
			{ "<leader>gb", builtin("git_branches"), desc = "Git Branches" },
			{ "<leader>gl", builtin("git_commits"), desc = "Git Log" },
			{ "<leader>gL", builtin("git_bcommits"), desc = "Git Log (buffer)" },
			{ "<leader>gs", builtin("git_status"), desc = "Git Status" },
			{ "<leader>gS", builtin("git_stash"), desc = "Git Stash" },

			-- gh
			{ "<leader>gi", gh("issues", { state = "open" }), desc = "GitHub Issues (open)" },
			{ "<leader>gI", gh("issues", { state = "all" }), desc = "GitHub Issues (all)" },
			{ "<leader>gp", gh("pull_request", { state = "open" }), desc = "GitHub Pull Requests (open)" },
			{ "<leader>gP", gh("pull_request", { state = "all" }), desc = "GitHub Pull Requests (all)" },
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					file_ignore_patterns = {
						"^%.git/",
						"%.png",
						"%.jpg",
						"%.jpeg",
						"%.gif",
						"%.webp",
						"%.avif",
						"%.ico",
						"%.svg",
						"%.bmp",
						"%.tiff",
						"%.pdf",
						"%.zip",
						"%.tar",
						"%.gz",
						"%.mp4",
						"%.mp3",
						"%.wav",
						"%.ttf",
						"%.woff",
						"%.woff2",
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			pcall(telescope.load_extension, "fzf")
			telescope.load_extension("ui-select")
			telescope.load_extension("gh")
		end,
	},
}
