return {
	"rest-nvim/rest.nvim",
	ft = "http",
	keys = {
		{ "<leader>Rs", "<cmd>Rest run<cr>", desc = "Send request", ft = "http" },
		{ "<leader>Rr", "<cmd>Rest last<cr>", desc = "Replay last request" },
		{ "<leader>Ro", "<cmd>Rest open<cr>", desc = "Open result pane" },
		{ "<leader>Re", "<cmd>Rest env select<cr>", desc = "Select env file", ft = "http" },
	},
}
