local theme_cache_file = vim.fn.stdpath("data") .. "/last_theme.txt"

local function get_saved_theme()
	local f = io.open(theme_cache_file, "r")
	if f then
		local theme = f:read("*l")
		f:close()
		return theme
	end
	return nil
end

local function save_theme(theme_name)
	local f = io.open(theme_cache_file, "w")
	if f then
		f:write(theme_name)
		f:close()
	end
end

require("kanagawa").setup({
	compile = false,
	undercurl = true,
	commentStyle = { italic = true },
	functionStyle = {},
	keywordStyle = { bold = false, italic = false },
	statementStyle = { bold = false },
	typeStyle = {},
	transparent = false,
	dimInactive = false,
	terminalColors = true,
	colors = {
		palette = {},
		theme = {
			lotus = {
				ui = {
					bg = "#f2ecde",
					bg_gutter = "#f2ecde",
					bg_pmenu = "#e9e2d0",
					bg_m3 = "#e9e2d0",
				},
			},
			wave = {},
			dragon = {},
			all = {},
		},
	},
	overrides = function(colors)
		local theme = colors.theme
		if theme.ui.bg == "#f2ecde" then
			return {
				Normal = { fg = theme.ui.fg, bg = theme.ui.bg },
				WinSeparator = { fg = "#d5cfc0", bold = true },
				ColorColumn = { bg = "#e5dfd0" },
				NormalFloat = { bg = theme.ui.bg_pmenu },
				FloatBorder = { fg = "#d5cfc0", bg = theme.ui.bg_pmenu },

				CursorLine = { bg = "NONE", bold = false },
				CursorLineNr = { bg = "NONE", fg = "#ff9e3b", bold = false },

				NvimTreeFolderName = { fg = "#5d5c55" },
				NvimTreeFolderIcon = { fg = "#8a7a63" },
				NvimTreeOpenedFolderIcon = { fg = "#8a7a63" },

				MiniIndentscopeSymbol = { fg = "#d5cfc0" },
				MiniPickCursorLine = { bg = theme.ui.bg_pmenu, fg = theme.ui.fg, bold = true },
				MiniPickMatchCurrent = { fg = theme.diag.warning, bold = true },
			}
		else
			return {
				WinSeparator = { fg = "#444444", bold = true },
				SignColumn = { bg = "NONE" },
				CursorLine = { bg = "NONE", bold = false },
				CursorLineNr = { bg = "NONE", fg = "#ff9e3b", bold = false },
				LineNr = { bg = "NONE", fg = "#555555", bold = false },

				MiniIndentscopeSymbol = { fg = "#444444" },
				MiniPickCursorLine = { bg = theme.ui.bg_pmenu, fg = theme.ui.fg, bold = true },
				MiniPickMatchCurrent = { fg = theme.diag.warning, bold = true },

				-- Blink
				BlinkCmpMenu = { fg = theme.ui.fg, bg = theme.ui.bg_p1 },
				BlinkCmpMenuBorder = { fg = theme.ui.float.fg_border, bg = theme.ui.bg_p1 },
				BlinkCmpDoc = { fg = theme.ui.fg, bg = theme.ui.bg_p2 },
				BlinkCmpDocBorder = { fg = theme.ui.float.fg_border, bg = theme.ui.bg_p2 },
				BlinkCmpMenuSelection = { bg = theme.ui.bg_p2, fg = theme.ui.fg_active },

				-- UI
				StatusLine = { fg = "#c5c9c5", bg = "#333333" },
			}
		end
	end,
	theme = "dragon",
	background = { dark = "dragon", light = "lotus" },
})

local function toggle_kanagawa()
	if vim.o.background == "dark" then
		vim.o.background = "light"
		vim.cmd("colorscheme kanagawa-lotus")
		save_theme("lotus")
	else
		vim.o.background = "dark"
		vim.cmd("colorscheme kanagawa-dragon")
		save_theme("dragon")
	end
end

local saved = get_saved_theme()
if saved == "lotus" then
	vim.o.background = "light"
	vim.cmd("colorscheme kanagawa-lotus")
else
	vim.o.background = "dark"
	vim.cmd("colorscheme kanagawa-dragon")
end

vim.keymap.set("n", "<leader>.", toggle_kanagawa, { noremap = true, silent = true, desc = "Toggle Kanagawa Variant" })

-- local function set_kanagawa_variant()
--     local hour = tonumber(os.date("%H"))
--     if hour >= 6 and hour < 17 then
--         vim.cmd.colorscheme("kanagawa-lotus")
--     else
--         vim.cmd.colorscheme("kanagawa-dragon")
--     end
-- end
--
-- set_kanagawa_variant()
--
-- vim.keymap.set("n", "<leader>/", set_kanagawa_variant, { noremap = true, silent = true })
--
-- local timer = vim.loop.new_timer()
-- timer:start(0, 3600000, vim.schedule_wrap(function()
--     local current = vim.g.colors_name or ""
--     if current:match("^kanagawa") then
--         set_kanagawa_variant()
--     end
-- end))

-- vim.cmd("colorscheme kanagawa")
