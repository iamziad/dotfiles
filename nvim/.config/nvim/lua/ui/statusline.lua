local M = {}
local has_devicons, devicons = pcall(require, "nvim-web-devicons")

vim.o.laststatus = 3
vim.o.showmode = false
vim.o.showcmd = false

-- ======================
-- Components
-- ======================

local function mode()
	local map = {
		n = "NORMAL",
		i = "INSERT",
		v = "VISUAL",
		V = "V-LINE",
		["\22"] = "V-BLOCK",
		c = "COMMAND",
		R = "REPLACE",
		t = "TERMINAL",
	}
	return map[vim.fn.mode()] or vim.fn.mode()
end

local function filename()
	if vim.bo.buftype ~= "" then
		return "[" .. vim.bo.filetype .. "]"
	end

	local name = vim.fn.expand("%:t")
	if name == "" then
		name = "[No Name]"
	end

	if vim.bo.modified then
		name = name .. " [+]"
	end

	if vim.bo.readonly then
		name = name .. " [RO]"
	end

	return name
end

local function filetype()
	local ft = vim.bo.filetype
	if ft == "" then
		return ""
	end
	return ft
end

local function git_branch()
	if vim.bo.buftype ~= "" then
		return ""
	end

	local filepath = vim.fn.expand("%:p")
	if filepath == "" or filepath:match("^oil://") then
		return ""
	end

	if vim.b.git_branch ~= nil then
		return vim.b.git_branch
	end

	local git_dir = vim.fs.find(".git", {
		upward = true,
		path = vim.fn.expand("%:p:h"),
	})[1]

	if not git_dir then
		vim.b.git_branch = ""
		return ""
	end

	local head_path = git_dir .. "/HEAD"

	if vim.fn.filereadable(head_path) == 0 then
		vim.b.git_branch = ""
		return ""
	end

	local head = vim.fn.readfile(head_path)[1] or ""
	local branch = head:match("ref: refs/heads/(.+)")

	vim.b.git_branch = branch and (" " .. branch) or ""
	return vim.b.git_branch
end

local function position()
	return string.format("%d:%d", vim.fn.line("."), vim.fn.col("."))
end

-- ======================
-- Builder
-- ======================

function M.build()
	local left = table.concat({
		" ",
		mode(),
		" | ",
		filename(),
	})

	local right_parts = {}

	local branch = git_branch()
	if branch ~= "" then
		table.insert(right_parts, branch)
	end

	local ft = filetype()
	if ft ~= "" then
		table.insert(right_parts, ft)
	end

	table.insert(right_parts, position())

	local right = table.concat(right_parts, " | ")

	return left .. "%=" .. right .. " "
end

vim.o.statusline = "%!v:lua.require('ui.statusline').build()"

return M
