local function list()
	return require("harpoon"):list()
end

local function toggle_telescope(harpoon_files)
	local conf = require("telescope.config").values
	local file_paths = {}
	for _, item in ipairs(harpoon_files.items) do
		table.insert(file_paths, item.value)
	end

	require("telescope.pickers")
		.new({}, {
			prompt_title = "Harpoon",
			finder = require("telescope.finders").new_table({
				results = file_paths,
			}),
			previewer = conf.file_previewer({}),
			sorter = conf.generic_sorter({}),
		})
		:find()
end

local keys = {
	{
		"<leader>fh",
		function()
			toggle_telescope(list())
		end,
		desc = "Open harpoon window",
	},
	{
		"<leader>a",
		function()
			list():add()
		end,
		desc = "Harpoon add file",
	},
	{
		"<leader>l",
		function()
			require("harpoon").ui:toggle_quick_menu(list())
		end,
		desc = "Harpoon quick menu",
	},
	-- Toggle previous & next buffers stored within Harpoon list
	{
		"<M-p>",
		function()
			list():prev()
		end,
		desc = "Harpoon prev",
	},
	{
		"<M-n>",
		function()
			list():next()
		end,
		desc = "Harpoon next",
	},
}

for i = 1, 4 do
	table.insert(keys, {
		"<leader>" .. i,
		function()
			list():select(i)
		end,
		desc = "Harpoon file " .. i,
	})
end

return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
	keys = keys,
	config = function()
		require("harpoon"):setup({})
	end,
}
