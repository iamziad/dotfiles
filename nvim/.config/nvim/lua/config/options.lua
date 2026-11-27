-- Editor settings. `vim.o.xxx = value` is the same as `:set xxx=value`.
local o = vim.o

-- Line numbers --------------------------------------------------------------
o.number = true            -- show the absolute number of the current line
o.relativenumber = true    -- show distance from the cursor on other lines (helps with 5j, 12k, ...)
o.signcolumn = 'yes'       -- always reserve the left column for git/diagnostic signs (no text jumping)
o.cursorline = true        -- highlight the line the cursor is on

-- Indentation (2 spaces by default; java.lua changes it to 4 for Java) -------
o.expandtab = true         -- Tab key inserts spaces
o.shiftwidth = 2           -- size of one indent level
o.tabstop = 2              -- how wide a Tab character is displayed
o.smartindent = true       -- auto-indent new lines

-- Searching -----------------------------------------------------------------
o.ignorecase = true        -- search is case-insensitive...
o.smartcase = true         -- ...unless you type a capital letter
o.inccommand = 'split'     -- live preview of :%s/old/new/ in a split

-- Windows -------------------------------------------------------------------
o.splitright = true        -- :vsplit opens on the right
o.splitbelow = true        -- :split opens below
o.winborder = 'rounded'    -- rounded borders on all floating windows (hover, diagnostics, ...)

-- Scrolling / display -------------------------------------------------------
o.scrolloff = 8            -- keep 8 lines visible above/below the cursor
o.wrap = false             -- don't wrap long lines
o.showmode = false         -- the statusline already shows the mode
o.pumheight = 12           -- max height of the completion popup
o.list = true              -- show invisible characters...
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }  -- ...tabs and trailing spaces

-- Files ---------------------------------------------------------------------
o.undofile = true          -- keep undo history even after closing the file
o.swapfile = false         -- no .swp files
o.confirm = true           -- ask "save changes?" instead of failing on :q
o.autoread = true          -- reload a file if it changed on disk

-- Behaviour -----------------------------------------------------------------
o.mouse = 'a'              -- mouse works everywhere
o.updatetime = 250         -- faster CursorHold events (used by diagnostics/gitsigns)
o.timeoutlen = 400         -- how long to wait for the next key of a shortcut (which-key shows after this)
o.termguicolors = true     -- 24-bit colors (needed by gruvbox-material)

-- Folding using treesitter. `za` toggles a fold, `zR` opens all, `zM` closes all.
o.foldmethod = 'expr'
o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
o.foldlevelstart = 99      -- start with everything unfolded

-- Use the system clipboard (so y / p work with other apps).
-- Needs `xclip` (X11) or `wl-clipboard` (Wayland). Set after startup to keep startup fast.
vim.schedule(function()
  o.clipboard = 'unnamedplus'
end)

-- Briefly highlight the text you just yanked.
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.hl.on_yank()
  end,
})
