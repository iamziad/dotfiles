local opt = vim.opt
local cmd = vim.cmd
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Auto-detect active nvm node and add to PATH
local nvm_dir = vim.env.HOME .. "/.nvm/versions/node"
local handle = io.popen("ls -1 " .. nvm_dir .. " 2>/dev/null | tail -1")
if handle then
	local version = handle:read("*l")
	handle:close()
	if version then
		vim.env.PATH = nvm_dir .. "/" .. version .. "/bin:" .. vim.env.PATH
	end
end

vim.env.NVIM_APPNAME = vim.env.NVIM_APPNAME or "nvim"
local pack_path = vim.fn.expand("$XDG_DATA_HOME/$NVIM_APPNAME/site")
vim.o.packpath = vim.o.packpath .. "," .. pack_path
-- ====================================================================
-- CORE MODULES
-- ====================================================================

require("config.options")
require("config.keymaps")
require("config.autocmd")

require("ui.statusline")
-- require("ui.statusline-minimal")
require("ui.fterminal")

require("utils.vargs")

-- ============================================================================
-- PLUGINS
-- ============================================================================

vim.pack.add({
	"https://github.com/rebelot/kanagawa.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/rose-pine/neovim",
	"https://github.com/morhetz/gruvbox.git",
    "https://github.com/ellisonleao/gruvbox.nvim",

	"https://www.github.com/echasnovski/mini.nvim",
	"https://www.github.com/ibhagwan/fzf-lua",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/christoomey/vim-tmux-navigator",
	"https://github.com/abecodes/tabout.nvim",
	"https://github.com/folke/flash.nvim",
	"https://github.com/norcalli/nvim-colorizer.lua",
	"https://www.github.com/lewis6991/gitsigns.nvim",
	"https://github.com/folke/which-key.nvim",
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
	},

	-- Language Server Protocols
	"https://www.github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/creativenull/efmls-configs-nvim",
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	"https://github.com/L3MON4D3/LuaSnip",

	-- Git Integration
	"https://github.com/malewicz1337/oil-git.nvim.git",

	-- Markdown
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
	"https://github.com/iamcco/markdown-preview.nvim.git",
})

local function packadd(name)
	vim.cmd("packadd " .. name)
end

packadd("kanagawa.nvim")
packadd("gruvbox.nvim")
packadd("neovim")

packadd("mini.nvim")
packadd("fzf-lua")
packadd("nvim-treesitter")
packadd("oil.nvim")
packadd("vim-tmux-navigator")
packadd("tabout.nvim")

packadd("nvim-lspconfig")
packadd("mason.nvim")
packadd("blink.cmp")

-- want to get rid of
packadd("markdown-preview.nvim")
packadd("which-key.nvim")
packadd("nvim-colorizer.lua")
packadd("flash.nvim")
packadd("gitsigns.nvim")

-- ============================================================================
-- PLUGINS CONFIG
-- ============================================================================

-- require("plugins.mini-pick")
require("plugins.mini-misc")
require("plugins.mini-sessions")
require("plugins.mini-indentscope")
require("plugins.mini-cursorword")
require("plugins.mini-trailspace")
require("plugins.mini-notify")

require("plugins.treesitter")
require("plugins.fzf-lua")
require("plugins.gitsigns")
require("plugins.oil")
require("plugins.lsp")
-- require("plugins.kanagawa")
require("plugins.vim-tmux-navigator")
require("plugins.tabout")
require("plugins.flash")
require("plugins.colorizer")

require("plugins.oil-git")

require("plugins.render-markdown")
