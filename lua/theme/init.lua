local M = {}

local uv = vim.uv or vim.loop
local OMARCHY_CURRENT_DIR = vim.fn.expand("~/.local/state/omarchy/current")
local OMARCHY_COLORS_PATH = OMARCHY_CURRENT_DIR .. "/theme/nvim-colors.lua"

local state = _G.__wallust_theme_state or {}
_G.__wallust_theme_state = state

local function parse_hex(hex)
	if type(hex) ~= "string" then
		return 0, 0, 0
	end
	local h = hex:gsub("^#", "")
	if #h ~= 6 then
		return 0, 0, 0
	end
	return tonumber(h:sub(1, 2), 16) or 0, tonumber(h:sub(3, 4), 16) or 0, tonumber(h:sub(5, 6), 16) or 0
end

local function blend(hex1, hex2, factor)
	local r1, g1, b1 = parse_hex(hex1)
	local r2, g2, b2 = parse_hex(hex2)
	return string.format(
		"#%02x%02x%02x",
		math.floor(r1 * factor + r2 * (1 - factor) + 0.5),
		math.floor(g1 * factor + g2 * (1 - factor) + 0.5),
		math.floor(b1 * factor + b2 * (1 - factor) + 0.5)
	)
end

local function is_light_hex(hex)
	local r, g, b = parse_hex(hex)
	-- Perceived luminance (Rec. 709)
	return (0.2126 * r + 0.7152 * g + 0.0722 * b) > 140
end

function M.load_palette()
	-- Prefer Omarchy's rendered theme table when present; fall back to wallust
	local colors_path = uv.fs_stat(OMARCHY_COLORS_PATH) and OMARCHY_COLORS_PATH
		or (vim.fn.stdpath("config") .. "/lua/theme/colors.lua")

	-- dofile() bypasses the Lua module cache and reads directly from disk
	local ok, raw = pcall(dofile, colors_path)
	if not ok or type(raw) ~= "table" then
		vim.notify("Theme colors not found at " .. colors_path, vim.log.levels.WARN)
		return nil
	end

	local mode = (raw.mode == "light" or raw.mode == "dark") and raw.mode
		or (is_light_hex(raw.background) and "light" or "dark")

	local bg = raw.background
	local fg = raw.foreground
	local accent = raw.accent or raw.color4
	local surface = raw.dark_background or raw.color0 or blend(fg, bg, 0.08)
	local surface_alt = raw.lighter_background or raw.color0 or blend(fg, bg, 0.12)
	local muted = raw.muted or raw.color8 or blend(fg, bg, 0.45)

	local c = vim.tbl_extend("force", {}, raw, {
		mode = mode,
		background = bg,
		foreground = fg,
		accent = accent,
		surface = surface,
		surface_alt = surface_alt,
		darker_background = raw.darker_background or surface,
		dark_foreground = raw.dark_foreground or muted,
		light_foreground = raw.light_foreground or raw.color7 or fg,
		bright_foreground = raw.bright_foreground or raw.color15 or fg,
		selection = raw.selection or blend(accent, bg, mode == "light" and 0.22 or 0.30),
		muted = muted,
		orange = raw.orange or raw.color3,
		brown = raw.brown or raw.color3,
	})

	M.palette = c
	return c
end

function M.setup()
	local c = M.load_palette()
	if not c then
		return
	end

	if vim.o.background ~= c.mode then
		vim.o.background = c.mode
	end

	local hl = vim.api.nvim_set_hl
	local is_light = c.mode == "light"
	local cursorline_bg = blend(c.foreground, c.background, is_light and 0.06 or 0.10)
	local visual_bg = c.selection
	local subtle_border = blend(c.accent, c.background, is_light and 0.65 or 0.80)

	-- Base UI (transparent so terminal/Glassy background shows through)
	hl(0, "Normal", { fg = c.foreground, bg = "NONE" })
	hl(0, "NormalNC", { fg = c.foreground, bg = "NONE" })
	hl(0, "NormalFloat", { fg = c.foreground, bg = "NONE" })
	hl(0, "FloatBorder", { fg = subtle_border, bg = "NONE" })
	hl(0, "FloatTitle", { fg = c.accent, bg = "NONE", bold = true })
	hl(0, "FloatFooter", { fg = c.muted, bg = "NONE" })
	hl(0, "FloatShadow", { bg = "NONE" })
	hl(0, "FloatShadowThrough", { bg = "NONE" })
	hl(0, "WinBar", { fg = c.foreground, bg = "NONE" })
	hl(0, "WinBarNC", { fg = c.muted, bg = "NONE" })
	hl(0, "MsgArea", { fg = c.foreground, bg = "NONE" })

	-- Telescope
	hl(0, "TelescopeNormal", { fg = c.foreground, bg = "NONE" })
	hl(0, "TelescopeBorder", { fg = subtle_border, bg = "NONE" })
	hl(0, "TelescopeTitle", { fg = c.accent, bg = "NONE", bold = true })
	hl(0, "TelescopePromptNormal", { fg = c.foreground, bg = "NONE" })
	hl(0, "TelescopePromptBorder", { fg = subtle_border, bg = "NONE" })
	hl(0, "TelescopePromptPrefix", { fg = c.accent, bg = "NONE", bold = true })
	hl(0, "TelescopePromptTitle", { fg = c.accent, bg = "NONE", bold = true })
	hl(0, "TelescopePromptCounter", { fg = c.muted, bg = "NONE" })
	hl(0, "TelescopeResultsNormal", { fg = c.foreground, bg = "NONE" })
	hl(0, "TelescopeResultsBorder", { fg = subtle_border, bg = "NONE" })
	hl(0, "TelescopeResultsTitle", { fg = c.accent, bg = "NONE", bold = true })
	hl(0, "TelescopePreviewNormal", { fg = c.foreground, bg = "NONE" })
	hl(0, "TelescopePreviewBorder", { fg = subtle_border, bg = "NONE" })
	hl(0, "TelescopePreviewTitle", { fg = c.accent, bg = "NONE", bold = true })
	hl(0, "TelescopeSelection", { fg = c.bright_foreground, bg = visual_bg, bold = true })
	hl(0, "TelescopeSelectionCaret", { fg = c.accent, bg = visual_bg, bold = true })
	hl(0, "TelescopeMatching", { fg = c.accent, bold = true })

	-- Cursor & selection
	hl(0, "ColorColumn", { bg = cursorline_bg })
	hl(0, "CursorLine", { bg = cursorline_bg })
	hl(0, "CursorColumn", { bg = cursorline_bg })
	hl(0, "CursorLineNr", { fg = c.accent, bg = "NONE", bold = true })
	hl(0, "Visual", { bg = visual_bg })
	hl(0, "VisualNOS", { bg = blend(c.accent, c.background, 0.20) })

	-- Line numbers & signs
	hl(0, "LineNr", { fg = c.muted, bg = "NONE" })
	hl(0, "SignColumn", { bg = "NONE" })
	hl(0, "FoldColumn", { fg = c.muted, bg = "NONE" })
	hl(0, "Folded", { fg = c.muted, bg = c.surface_alt, italic = true })

	-- Search
	hl(0, "Search", { fg = c.background, bg = c.color3 })
	hl(0, "IncSearch", { fg = c.background, bg = c.accent })
	hl(0, "CurSearch", { fg = c.background, bg = c.accent, bold = true })
	hl(0, "Substitute", { fg = c.background, bg = c.color1 })

	-- Status & tab line
	hl(0, "StatusLine", { fg = c.foreground, bg = "NONE" })
	hl(0, "StatusLineNC", { fg = c.muted, bg = "NONE" })
	hl(0, "TabLine", { fg = c.muted, bg = "NONE" })
	hl(0, "TabLineSel", { fg = c.foreground, bg = "NONE", bold = true })
	hl(0, "TabLineFill", { bg = "NONE" })

	-- Window separators
	hl(0, "WinSeparator", { fg = c.surface_alt })

	-- Popup menu & blink.cmp
	hl(0, "Pmenu", { fg = c.foreground, bg = "NONE" })
	hl(0, "PmenuBorder", { fg = subtle_border, bg = "NONE" })
	hl(0, "PmenuSel", { fg = c.background, bg = c.accent, bold = true })
	hl(0, "PmenuSbar", { bg = "NONE" })
	hl(0, "PmenuThumb", { bg = c.muted })
	hl(0, "PmenuShadow", { link = "FloatShadow" })
	hl(0, "PmenuShadowThrough", { link = "FloatShadowThrough" })
	hl(0, "PmenuKind", { fg = c.accent, bg = "NONE" })
	hl(0, "PmenuExtra", { fg = c.muted, bg = "NONE" })
	hl(0, "BlinkCmpMenu", { fg = c.foreground, bg = "NONE" })
	hl(0, "BlinkCmpMenuBorder", { fg = subtle_border, bg = "NONE" })
	hl(0, "BlinkCmpMenuSelection", { fg = c.bright_foreground, bg = visual_bg, bold = true })
	hl(0, "BlinkCmpScrollBarThumb", { bg = c.muted })
	hl(0, "BlinkCmpScrollBarGutter", { bg = "NONE" })
	hl(0, "BlinkCmpDoc", { fg = c.foreground, bg = "NONE" })
	hl(0, "BlinkCmpDocBorder", { fg = subtle_border, bg = "NONE" })
	hl(0, "BlinkCmpDocSeparator", { fg = c.surface_alt, bg = "NONE" })
	hl(0, "BlinkCmpSignatureHelp", { fg = c.foreground, bg = "NONE" })
	hl(0, "BlinkCmpSignatureHelpBorder", { fg = subtle_border, bg = "NONE" })
	hl(0, "BlinkCmpLabel", { fg = c.foreground })
	hl(0, "BlinkCmpLabelDeprecated", { fg = c.muted, strikethrough = true })
	hl(0, "BlinkCmpLabelMatch", { fg = c.accent, bold = true })
	hl(0, "BlinkCmpLabelDetail", { fg = c.muted })
	hl(0, "BlinkCmpLabelDescription", { fg = c.muted })
	hl(0, "BlinkCmpGhostText", { fg = c.muted, italic = true })
	hl(0, "BlinkCmpKindText", { fg = c.foreground })
	hl(0, "BlinkCmpKindMethod", { fg = c.color4 })
	hl(0, "BlinkCmpKindFunction", { fg = c.color4 })
	hl(0, "BlinkCmpKindConstructor", { fg = c.color6 })
	hl(0, "BlinkCmpKindField", { fg = c.color6 })
	hl(0, "BlinkCmpKindVariable", { fg = c.foreground })
	hl(0, "BlinkCmpKindClass", { fg = c.color3 })
	hl(0, "BlinkCmpKindInterface", { fg = c.color3 })
	hl(0, "BlinkCmpKindModule", { fg = c.color6 })
	hl(0, "BlinkCmpKindProperty", { fg = c.color6 })
	hl(0, "BlinkCmpKindUnit", { fg = c.color3 })
	hl(0, "BlinkCmpKindValue", { fg = c.color3 })
	hl(0, "BlinkCmpKindEnum", { fg = c.color3 })
	hl(0, "BlinkCmpKindKeyword", { fg = c.color5 })
	hl(0, "BlinkCmpKindSnippet", { fg = c.color2 })
	hl(0, "BlinkCmpKindColor", { fg = c.color5 })
	hl(0, "BlinkCmpKindFile", { fg = c.color4 })
	hl(0, "BlinkCmpKindReference", { fg = c.color6 })
	hl(0, "BlinkCmpKindFolder", { fg = c.color4 })
	hl(0, "BlinkCmpKindEnumMember", { fg = c.color3 })
	hl(0, "BlinkCmpKindConstant", { fg = c.orange })
	hl(0, "BlinkCmpKindStruct", { fg = c.color3 })
	hl(0, "BlinkCmpKindEvent", { fg = c.color5 })
	hl(0, "BlinkCmpKindOperator", { fg = c.color5 })
	hl(0, "BlinkCmpKindTypeParameter", { fg = c.color6 })

	-- which-key
	hl(0, "WhichKey", { fg = c.accent, bold = true })
	hl(0, "WhichKeyGroup", { fg = c.color5 })
	hl(0, "WhichKeyDesc", { fg = c.foreground })
	hl(0, "WhichKeySeparator", { fg = c.muted })
	hl(0, "WhichKeyNormal", { fg = c.foreground, bg = "NONE" })
	hl(0, "WhichKeyFloat", { fg = c.foreground, bg = "NONE" })
	hl(0, "WhichKeyBorder", { fg = subtle_border, bg = "NONE" })
	hl(0, "WhichKeyTitle", { fg = c.accent, bg = "NONE", bold = true })
	hl(0, "WhichKeyValue", { fg = c.muted })

	-- Incline
	hl(0, "InclineNormal", { fg = c.foreground, bg = "NONE" })
	hl(0, "InclineNormalNC", { fg = c.muted, bg = "NONE" })
	hl(0, "InclineModified", { fg = c.orange, bg = "NONE" })

	-- Lazy & Mason
	hl(0, "LazyNormal", { fg = c.foreground, bg = "NONE" })
	hl(0, "LazyBackdrop", { bg = "NONE" })
	hl(0, "MasonNormal", { fg = c.foreground, bg = "NONE" })
	hl(0, "MasonBackdrop", { bg = "NONE" })
	hl(0, "MasonHeader", { fg = c.background, bg = c.accent, bold = true })
	hl(0, "MasonHeaderSecondary", { fg = c.background, bg = c.color6, bold = true })
	hl(0, "MasonHighlight", { fg = c.accent, bg = "NONE" })
	hl(0, "MasonHighlightBlock", { fg = c.background, bg = c.accent })
	hl(0, "MasonHighlightBlockBold", { fg = c.background, bg = c.accent, bold = true })
	hl(0, "MasonHighlightSecondary", { fg = c.color3, bg = "NONE" })
	hl(0, "MasonHighlightBlockSecondary", { fg = c.background, bg = c.color3 })
	hl(0, "MasonHighlightBlockBoldSecondary", { fg = c.background, bg = c.color3, bold = true })
	hl(0, "MasonMuted", { fg = c.muted, bg = "NONE" })
	hl(0, "MasonMutedBlock", { fg = c.foreground, bg = c.surface_alt })
	hl(0, "MasonMutedBlockBold", { fg = c.foreground, bg = c.surface_alt, bold = true })

	-- Misc UI
	hl(0, "MatchParen", { fg = c.accent, bg = visual_bg, bold = true, underline = true })
	hl(0, "EndOfBuffer", { fg = c.surface_alt })
	hl(0, "NonText", { fg = c.surface_alt })
	hl(0, "SpecialKey", { fg = c.muted })
	hl(0, "Whitespace", { fg = c.surface_alt })
	hl(0, "Title", { fg = c.accent, bold = true })
	hl(0, "Question", { fg = c.color2 })
	hl(0, "MoreMsg", { fg = c.color2 })
	hl(0, "ModeMsg", { fg = c.foreground, bold = true })
	hl(0, "ErrorMsg", { fg = c.color1, bold = true })
	hl(0, "WarningMsg", { fg = c.color3 })
	hl(0, "Directory", { fg = c.color4 })

	-- Syntax
	hl(0, "Comment", { fg = c.muted, italic = true })
	hl(0, "Constant", { fg = c.orange })
	hl(0, "String", { fg = c.color2 })
	hl(0, "Character", { fg = c.color2 })
	hl(0, "Number", { fg = c.orange })
	hl(0, "Boolean", { fg = c.orange })
	hl(0, "Float", { fg = c.orange })
	hl(0, "Identifier", { fg = c.foreground })
	hl(0, "Function", { fg = c.color4, bold = true })
	hl(0, "Statement", { fg = c.color5, italic = true })
	hl(0, "Keyword", { fg = c.color5, italic = true })
	hl(0, "Conditional", { fg = c.color5, italic = true })
	hl(0, "Repeat", { fg = c.color5, italic = true })
	hl(0, "Operator", { fg = c.color5 })
	hl(0, "Exception", { fg = c.color1 })
	hl(0, "PreProc", { fg = c.color6 })
	hl(0, "Include", { fg = c.color6 })
	hl(0, "Define", { fg = c.color6 })
	hl(0, "Macro", { fg = c.color6 })
	hl(0, "Type", { fg = c.color6 })
	hl(0, "StorageClass", { fg = c.color5 })
	hl(0, "Structure", { fg = c.color6 })
	hl(0, "Typedef", { fg = c.color6 })
	hl(0, "Special", { fg = c.color4 })
	hl(0, "SpecialChar", { fg = c.color3 })
	hl(0, "Delimiter", { fg = c.light_foreground })
	hl(0, "Underlined", { underline = true })
	hl(0, "Error", { fg = c.color1, bold = true })
	hl(0, "Todo", { fg = c.background, bg = c.color3, bold = true })

	-- Treesitter (Neovim 0.12 / nvim-treesitter main captures + legacy aliases)
	hl(0, "@comment", { link = "Comment" })
	hl(0, "@keyword", { link = "Keyword" })
	hl(0, "@keyword.return", { fg = c.color1, italic = true })
	hl(0, "@keyword.operator", { fg = c.color5 })
	hl(0, "@keyword.import", { fg = c.color6 })
	hl(0, "@function", { link = "Function" })
	hl(0, "@function.builtin", { fg = c.color4 })
	hl(0, "@function.call", { fg = c.color4 })
	hl(0, "@function.method", { fg = c.color4, bold = true })
	hl(0, "@function.method.call", { fg = c.color4 })
	hl(0, "@method", { link = "@function.method" })
	hl(0, "@method.call", { link = "@function.method.call" })
	hl(0, "@string", { link = "String" })
	hl(0, "@string.escape", { fg = c.color3 })
	hl(0, "@string.regexp", { fg = c.orange })
	hl(0, "@number", { link = "Number" })
	hl(0, "@number.float", { link = "Float" })
	hl(0, "@float", { link = "Float" })
	hl(0, "@boolean", { link = "Boolean" })
	hl(0, "@type", { fg = c.color6 })
	hl(0, "@type.builtin", { fg = c.color6, italic = true })
	hl(0, "@variable", { fg = c.foreground })
	hl(0, "@variable.builtin", { fg = c.color5, italic = true })
	hl(0, "@variable.parameter", { fg = c.foreground, italic = true })
	hl(0, "@variable.member", { fg = c.color6 })
	hl(0, "@parameter", { link = "@variable.parameter" })
	hl(0, "@field", { link = "@variable.member" })
	hl(0, "@property", { fg = c.color6 })
	hl(0, "@module", { fg = c.color6 })
	hl(0, "@namespace", { link = "@module" })
	hl(0, "@constant", { fg = c.orange })
	hl(0, "@constant.builtin", { fg = c.orange, italic = true })
	hl(0, "@constructor", { fg = c.color6, bold = true })
	hl(0, "@operator", { fg = c.color5 })
	hl(0, "@punctuation.bracket", { fg = c.light_foreground })
	hl(0, "@punctuation.delimiter", { fg = c.light_foreground })
	hl(0, "@punctuation.special", { fg = c.color5 })
	hl(0, "@tag", { fg = c.color1 })
	hl(0, "@tag.attribute", { fg = c.color3 })
	hl(0, "@tag.delimiter", { fg = c.muted })
	hl(0, "@attribute", { fg = c.color3 })
	hl(0, "@markup.heading", { fg = c.accent, bold = true })
	hl(0, "@markup.strong", { bold = true })
	hl(0, "@markup.italic", { italic = true })
	hl(0, "@markup.link", { fg = c.color4, underline = true })
	hl(0, "@markup.raw", { fg = c.color2 })
	hl(0, "@markup.list", { fg = c.color5 })
	hl(0, "@diff.plus", { fg = c.color2 })
	hl(0, "@diff.minus", { fg = c.color1 })
	hl(0, "@diff.delta", { fg = c.color3 })

	-- Diagnostics
	hl(0, "DiagnosticError", { fg = c.color1 })
	hl(0, "DiagnosticWarn", { fg = c.color3 })
	hl(0, "DiagnosticInfo", { fg = c.color6 })
	hl(0, "DiagnosticHint", { fg = c.color5 })
	hl(0, "DiagnosticOk", { fg = c.color2 })
	hl(0, "DiagnosticUnderlineError", { sp = c.color1, undercurl = true })
	hl(0, "DiagnosticUnderlineWarn", { sp = c.color3, undercurl = true })
	hl(0, "DiagnosticUnderlineInfo", { sp = c.color6, undercurl = true })
	hl(0, "DiagnosticUnderlineHint", { sp = c.color5, undercurl = true })
	hl(0, "DiagnosticVirtualTextError", { fg = c.color1, bg = "NONE", italic = true })
	hl(0, "DiagnosticVirtualTextWarn", { fg = c.color3, bg = "NONE", italic = true })
	hl(0, "DiagnosticVirtualTextInfo", { fg = c.color6, bg = "NONE", italic = true })
	hl(0, "DiagnosticVirtualTextHint", { fg = c.color5, bg = "NONE", italic = true })
	hl(0, "DiagnosticSignError", { fg = c.color1, bg = "NONE" })
	hl(0, "DiagnosticSignWarn", { fg = c.color3, bg = "NONE" })
	hl(0, "DiagnosticSignInfo", { fg = c.color6, bg = "NONE" })
	hl(0, "DiagnosticSignHint", { fg = c.color5, bg = "NONE" })

	-- LSP
	hl(0, "LspReferenceText", { bg = c.surface_alt, underline = true })
	hl(0, "LspReferenceRead", { bg = c.surface_alt, underline = true })
	hl(0, "LspReferenceWrite", { bg = c.surface_alt, bold = true, underline = true })
	hl(0, "LspInlayHint", { fg = c.muted, bg = "NONE", italic = true })
	hl(0, "LspCodeLens", { fg = c.muted, bg = "NONE", italic = true })
	hl(0, "LspCodeLensSeparator", { fg = c.muted, bg = "NONE" })

	-- Git signs
	hl(0, "GitSignsAdd", { fg = c.color2, bg = "NONE" })
	hl(0, "GitSignsChange", { fg = c.color3, bg = "NONE" })
	hl(0, "GitSignsDelete", { fg = c.color1, bg = "NONE" })
	hl(0, "GitSignsAddNr", { fg = c.color2 })
	hl(0, "GitSignsChangeNr", { fg = c.color3 })
	hl(0, "GitSignsDeleteNr", { fg = c.color1 })

	-- Diff & Diffview
	local diff_alpha = is_light and 0.14 or 0.16
	hl(0, "DiffAdd", { bg = blend(c.color2, c.background, diff_alpha) })
	hl(0, "DiffChange", { bg = blend(c.color3, c.background, diff_alpha) })
	hl(0, "DiffDelete", { fg = c.color1, bg = blend(c.color1, c.background, diff_alpha) })
	hl(0, "DiffText", { bg = blend(c.color4, c.background, diff_alpha + 0.10), bold = true })
	hl(0, "DiffviewFilePanelTitle", { fg = c.accent, bold = true })
	hl(0, "DiffviewFilePanelCounter", { fg = c.color5, bold = true })
	hl(0, "DiffviewFilePanelFileName", { fg = c.foreground })
	hl(0, "DiffviewStatusAdded", { fg = c.color2 })
	hl(0, "DiffviewStatusModified", { fg = c.color3 })
	hl(0, "DiffviewStatusRenamed", { fg = c.color6 })
	hl(0, "DiffviewStatusDeleted", { fg = c.color1 })

	-- Oil Git
	hl(0, "OilGitAdded", { fg = c.color2 })
	hl(0, "OilGitModified", { fg = c.color3 })
	hl(0, "OilGitUntracked", { fg = c.color4 })
	hl(0, "OilGitRenamed", { fg = c.color6 })
	hl(0, "OilGitCopied", { fg = c.color6 })
	hl(0, "OilGitDeleted", { fg = c.color1 })
	hl(0, "OilGitIgnored", { fg = c.muted })
	hl(0, "OilGitUnmerged", { fg = c.color1 })

	-- nvim-dap
	hl(0, "DapUIFloatNormal", { fg = c.foreground, bg = "NONE" })
	hl(0, "DapUIFloatBorder", { fg = subtle_border, bg = "NONE" })
	hl(0, "DapBreakpoint", { fg = c.color1, bg = "NONE" })
	hl(0, "DapBreakpointCondition", { fg = c.color3, bg = "NONE" })
	hl(0, "DapBreakpointRejected", { fg = c.muted, bg = "NONE" })
	hl(0, "DapLogPoint", { fg = c.color6, bg = "NONE" })
	hl(0, "DapStopped", { fg = c.color2, bg = "NONE" })
	hl(0, "DapStoppedLine", { bg = blend(c.color2, c.background, 0.2) })
	hl(0, "NvimDapVirtualText", { fg = c.muted, bg = "NONE", italic = true })
	hl(0, "NvimDapVirtualTextChanged", { fg = c.color3, bg = "NONE", italic = true })
	hl(0, "NvimDapVirtualTextError", { fg = c.color1, bg = "NONE", italic = true })
	hl(0, "NvimDapVirtualTextInfo", { fg = c.color6, bg = "NONE", italic = true })

	-- Aerial (outline)
	hl(0, "AerialNormal", { fg = c.foreground, bg = "NONE" })
	hl(0, "AerialNormalFloat", { fg = c.foreground, bg = "NONE" })
	hl(0, "AerialLine", { bg = c.surface_alt, bold = true })
	hl(0, "AerialGuide", { fg = c.muted })
	hl(0, "AerialClass", { fg = c.color3 })
	hl(0, "AerialInterface", { fg = c.color3, italic = true })
	hl(0, "AerialStruct", { fg = c.color3 })
	hl(0, "AerialEnum", { fg = c.color3 })
	hl(0, "AerialMethod", { fg = c.color4 })
	hl(0, "AerialFunction", { fg = c.color4 })
	hl(0, "AerialConstructor", { fg = c.color4 })
	hl(0, "AerialProperty", { fg = c.color6 })
	hl(0, "AerialField", { fg = c.color6 })
	hl(0, "AerialVariable", { fg = c.foreground })
	hl(0, "AerialNamespace", { fg = c.color5 })

	-- Terminal colors
	for i = 0, 15 do
		vim.g["terminal_color_" .. i] = c["color" .. i]
	end
	vim.g.terminal_color_background = c.background
	vim.g.terminal_color_foreground = c.foreground

	M.apply_plugin_overrides(c)

	-- Re-apply overrides after ColorScheme autocmds from plugins that hardcode hex colors
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("wallust_plugin_overrides", { clear = true }),
		pattern = "wallust",
		callback = function()
			vim.schedule(function()
				if vim.g.colors_name == "wallust" then
					require("theme").apply_plugin_overrides()
				end
			end)
		end,
	})
end

function M.apply_plugin_overrides(c)
	c = c or M.palette or M.load_palette()
	if not c then
		return
	end
	local hl = vim.api.nvim_set_hl
	local is_light = c.mode == "light"
	local subtle_border = blend(c.accent, c.background, is_light and 0.65 or 0.80)

	-- easy-dotnet hardcodes dark VS Code hex backgrounds on setup & ColorScheme
	hl(0, "EasyDotnetPackage", { fg = c.background, bg = c.accent, bold = true })
	hl(0, "EasyDotnetPeekWinBar", { fg = c.foreground, bg = "NONE", bold = true })
	hl(0, "EasyDotnetPeekSideBar", { fg = c.foreground, bg = "NONE" })
	hl(0, "EasyDotnetPeekMain", { fg = c.foreground, bg = "NONE" })
	hl(0, "EasyDotnetPeekBorder", { fg = subtle_border, bg = "NONE" })
	hl(0, "EasyDotnetPeekTitle", { fg = c.accent, bg = "NONE", bold = true })
	hl(0, "EasyDotnetPeekHint", { fg = c.muted, bg = "NONE", italic = true })
	hl(0, "EasyDotnetPeekListActive", { fg = c.bright_foreground, bg = c.selection, bold = true })
end

function M.reload()
	if not state.reload_timer then
		state.reload_timer = uv.new_timer()
	end
	state.reload_timer:stop()
	state.reload_timer:start(
		50,
		0,
		vim.schedule_wrap(function()
			-- Only repaint automatically when using our dynamic colorscheme
			if vim.g.colors_name and vim.g.colors_name ~= "wallust" then
				return
			end
			package.loaded["lualine.themes.wallust"] = nil
			vim.cmd.colorscheme("wallust")
			local ok, lualine = pcall(require, "lualine")
			if ok then
				lualine.refresh({ place = { "statusline" } })
			end
			vim.cmd("redraw!")
		end)
	)
end

function M.watch_omarchy()
	if state.watcher or not uv.fs_stat(OMARCHY_CURRENT_DIR) then
		return
	end
	local handle = uv.new_fs_event()
	if not handle then
		return
	end
	local ok = handle:start(OMARCHY_CURRENT_DIR, {}, function(err, filename)
		if err then
			return
		end
		if not filename or filename == "theme.generation" or filename == "theme.name" or filename == "theme" then
			M.reload()
		end
	end)
	if not ok then
		handle:close()
		return
	end
	state.watcher = handle
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = vim.api.nvim_create_augroup("omarchy_theme_watch", { clear = true }),
		callback = function()
			if state.watcher and not state.watcher:is_closing() then
				state.watcher:stop()
				state.watcher:close()
				state.watcher = nil
			end
			if state.reload_timer and not state.reload_timer:is_closing() then
				state.reload_timer:stop()
				state.reload_timer:close()
				state.reload_timer = nil
			end
		end,
	})
end

return M
