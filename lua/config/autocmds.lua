vim.filetype.add({
	extension = { jsonl = "json", jsonc = "json" },
	pattern = {
		["Dockerfile%..*"] = "dockerfile",
		["Containerfile%..*"] = "dockerfile",
	},
})

vim.api.nvim_create_autocmd("BufReadPre", {
	group = vim.api.nvim_create_augroup("large_file", { clear = true }),
	callback = function()
		local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
		if size > 100 * 1024 or size == -2 then
			vim.b.large_file = true
			vim.opt_local.foldmethod = "manual"
			vim.opt_local.spell = false
			vim.bo.syntax = "off"
		end
	end,
})

vim.o.autoread = true

vim.api.nvim_create_autocmd({ "FocusGained" }, {
	callback = function()
		if vim.fn.mode() ~= "c" then
			vim.cmd.checktime()
		end
	end,
})

local _sigusr1 = (vim.uv or vim.loop).new_signal()
_sigusr1:start("sigusr1", function()
	require("theme").reload()
end)

require("theme").watch_omarchy()

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "**/lua/theme/colors.lua",
	callback = function()
		vim.opt_local.swapfile = false
		vim.opt_local.undofile = false
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("yank_highlight", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- rest.nvim formats response bodies with the filetype's formatprg
vim.api.nvim_create_autocmd("FileType", {
	pattern = "json",
	callback = function(ev)
		vim.bo[ev.buf].formatprg = "jq"
	end,
})

-- Roslyn formats with the editor's indent options; use the usual C# 4 spaces instead of tabs
vim.api.nvim_create_autocmd("FileType", {
	pattern = "cs",
	callback = function(ev)
		vim.bo[ev.buf].expandtab = true
		vim.bo[ev.buf].shiftwidth = 4
		vim.bo[ev.buf].tabstop = 4
	end,
})

-- boot.dev lessons in ~/projects/learing: a lesson's code files mirror the code blocks of its note
-- (_scripts/run-lesson.py). Sync before reading so the buffer has the note's latest code, and after writing so the
-- note gets ours. <localleader>r / <localleader>t run the code / tests; the output lands in the note.
local learing = vim.fn.expand("~") .. "/projects/learing"
local lesson_files = { learing .. "/bootdev/**.go", learing .. "/bootdev/**.py", learing .. "/bootdev/**.sql" }
local function lesson(mode, file, on_exit)
	return vim.system({ "python3", learing .. "/_scripts/run-lesson.py", mode, file }, { text = true }, on_exit)
end
local lesson_group = vim.api.nvim_create_augroup("bootdev_lessons", { clear = true })
vim.api.nvim_create_autocmd("BufReadPre", {
	group = lesson_group,
	pattern = lesson_files,
	callback = function(ev)
		lesson("sync", ev.file):wait()
	end,
})
vim.api.nvim_create_autocmd("BufWritePost", {
	group = lesson_group,
	pattern = lesson_files,
	callback = function(ev)
		lesson("sync", ev.file, function(res)
			if res.code ~= 0 then
				vim.schedule(function()
					vim.notify("lesson sync: " .. res.stderr, vim.log.levels.ERROR)
				end)
			end
		end)
	end,
})
vim.api.nvim_create_autocmd("BufEnter", {
	group = lesson_group,
	pattern = lesson_files,
	callback = function(ev)
		for key, mode in pairs({ ["<localleader>r"] = "run", ["<localleader>t"] = "test" }) do
			vim.keymap.set("n", key, function()
				vim.cmd("silent! write")
				lesson(mode, ev.file, function(res)
					vim.schedule(function()
						local msg = vim.trim(res.stdout .. res.stderr)
						vim.notify(msg, res.code == 0 and vim.log.levels.INFO or vim.log.levels.WARN)
					end)
				end)
			end, { buffer = ev.buf, desc = "Lesson: " .. mode .. " (output in the note)" })
		end
	end,
})
