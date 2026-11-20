return {
	{
		"nvim-tree/nvim-web-devicons",
		priority = 1000,
		dependencies = { "DaikyXendo/nvim-material-icon" },
		config = function()
			local ok, material_icons = pcall(require, "nvim-material-icon")
			if not ok then
				require("nvim-web-devicons").setup({ default = true })
				return
			end
			require("nvim-web-devicons").setup({
				override = material_icons.get_icons(),
				default = true,
			})
		end,
	},
	{
		"b0o/incline.nvim",
		event = "VeryLazy",
		config = function()
			local devicons = require("nvim-web-devicons")
			require("incline").setup({
				window = {
					padding = 0,
					margin = { horizontal = 0 },
				},
				render = function(props)
					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
					if filename == "" then
						filename = "[No Name]"
					end
					local ft_icon, ft_color = devicons.get_icon_color(filename)
					local modified = vim.bo[props.buf].modified
					local palette = require("theme").palette
					local mod_fg = (palette and palette.orange) or "#d19a66"
					return {
						ft_icon and { " ", ft_icon, " ", guibg = "none", guifg = ft_color } or "",
						{ " " .. filename .. "", guibg = "none" },
						{ modified and " ● " or " ", guibg = "none", guifg = mod_fg },
					}
				end,
			})
		end,
	},
	-- theme
	-- colorscheme
	-- lua/plugins/rose-pine.lua
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = true,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
		opts = {
			flavour = "mocha",
			integrations = {
				gitsigns = true,
				telescope = { enabled = true },
				which_key = true,
				harpoon = true,
				blink_cmp = true,
				native_lsp = { enabled = true },
			},
		},
	},
	{
		"ellisonleao/gruvbox.nvim",
		lazy = true,
		config = function()
			require("gruvbox").setup({
				contrast = "",
			})
		end,
	},

	-- colors
	{
		"brenoprata10/nvim-highlight-colors",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			render = "virtual",
			virtual_symbol_position = "inline",
			virtual_symbol_suffix = " ",
			custom_colors = {
				{ label = "%-%-theme%-primary", color = "#0f1219" },
				{ label = "%-%-theme%-secondary", color = "#00ff00" },
			},
		},
	},
}
