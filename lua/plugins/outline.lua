return {
	{
		"stevearc/aerial.nvim",
		cmd = { "AerialToggle", "AerialNavToggle" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		keys = {
			{ "<leader>co", "<cmd>AerialToggle!<CR>", desc = "Toggle symbol outline" },
		},
		opts = {
			backends = { "lsp", "treesitter", "markdown" },
			layout = { default_direction = "prefer_right", min_width = 30 },
			show_guides = true,
			on_attach = function(buf)
				vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = buf, desc = "Previous symbol" })
				vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = buf, desc = "Next symbol" })
			end,
		},
	},
}
