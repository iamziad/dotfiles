local opt = vim.opt
local cmd = vim.cmd
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
-- ====================================================================
-- Options
-- ====================================================================
vim.visualbell = true

opt.termguicolors = true
cmd.colorscheme("gruvbox")
vim.opt.termbidi = true
vim.opt.showmode = false

-- Mics
opt.cursorline = true
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
vim.opt.guicursor = "n-v-c:block,i:block-blinkon0"
vim.opt.equalalways = true
vim.opt.colorcolumn = "80"
vim.opt.timeoutlen = 300 -- mapping timeout, ok to leave higher
vim.opt.ttimeoutlen = 10 -- terminal key sequences
vim.opt.wrap = false
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.updatetime = 300
opt.splitbelow = true
opt.splitright = true
opt.virtualedit = "block"
opt.backspace = { "start", "eol", "indent" }
vim.g.editorconfig = true

-- Indenting
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true

-- Undotree
opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- Searching
opt.hlsearch = false
opt.incsearch = true
opt.inccommand = "split"
opt.ignorecase = true
opt.smartcase = true

-- Netrw settings

vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 4 -- open files in prior window
vim.g.netrw_altv = 0 -- open files at right
vim.g.netrw_liststyle = 3

vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.pumheight = 10 -- Popup menu height

-- Folding: requires treesitter available at runtime; safe fallback if not
vim.opt.foldmethod = "expr" -- use expression for folding
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- use treesitter for folding
vim.opt.foldlevel = 99 -- start with all folds open
