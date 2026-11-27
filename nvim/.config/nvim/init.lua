-- ~/.config/nvim/init.lua
-- This file only decides the ORDER in which the other files are loaded.
-- Every file lives in lua/config/ and does one job.
--
-- Requires Neovim 0.12+ (uses the built-in plugin manager `vim.pack`
-- and the built-in LSP API `vim.lsp.config` / `vim.lsp.enable`).

-- The leader key is the "prefix" for your own shortcuts (e.g. <leader>ff).
-- It MUST be set before any mapping is created, so it goes first.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options") -- editor settings (numbers, tabs, search, ...)
require("config.plugins") -- list of plugins; installs them on first launch
require("config.ui") -- theme, statusline, which-key, file explorer, git, picker
require("config.treesitter") -- better syntax highlighting
require("config.completion") -- autocomplete popup (blink.cmp)
require("config.lsp") -- language servers (JS/TS/HTML/CSS/Tailwind/Angular/...)
require("config.java") -- everything Java-specific (jdtls)
require("config.format") -- format on save (prettier, google-java-format, ...)
require("config.keymaps") -- general shortcuts
