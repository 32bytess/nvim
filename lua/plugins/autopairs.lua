return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	opts = {
		check_ts = true, -- don't pair inside strings/comments
		map_cr = true, -- <CR> between {} opens an indented block
	},
}
