local theme = require("theme")
local c = theme.palette or theme.load_palette()

if not c then
	return require("lualine.themes.auto")
end

local b = { fg = c.foreground, bg = "NONE" }
local mid = { fg = c.light_foreground, bg = "NONE" }
local inactive = { fg = c.muted, bg = "NONE" }

return {
	normal = {
		a = { fg = c.background, bg = c.accent, gui = "bold" },
		b = b,
		c = mid,
	},
	insert = {
		a = { fg = c.background, bg = c.color2, gui = "bold" },
		b = b,
		c = mid,
	},
	visual = {
		a = { fg = c.background, bg = c.color3, gui = "bold" },
		b = b,
		c = mid,
	},
	replace = {
		a = { fg = c.background, bg = c.color1, gui = "bold" },
		b = b,
		c = mid,
	},
	command = {
		a = { fg = c.background, bg = c.color5, gui = "bold" },
		b = b,
		c = mid,
	},
	terminal = {
		a = { fg = c.background, bg = c.color6, gui = "bold" },
		b = b,
		c = mid,
	},
	inactive = {
		a = inactive,
		b = inactive,
		c = inactive,
	},
}
