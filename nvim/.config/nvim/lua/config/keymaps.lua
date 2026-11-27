-- General shortcuts. <leader> is the Space key.
-- Tip: press <Space> and wait, which-key will show you everything available.
local map = vim.keymap.set

-- Basics ---------------------------------------------------------------------
map('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })
map('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save file' })
map('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Quit window' })

-- Moving between split windows: Ctrl + h/j/k/l
map('n', '<C-h>', '<C-w>h', { desc = 'Window left' })
map('n', '<C-j>', '<C-w>j', { desc = 'Window down' })
map('n', '<C-k>', '<C-w>k', { desc = 'Window up' })
map('n', '<C-l>', '<C-w>l', { desc = 'Window right' })

-- Moving selected lines up/down in visual mode
map('v', 'J', ":m '>+1<cr>gv=gv", { desc = 'Move selection down' })
map('v', 'K', ":m '<-2<cr>gv=gv", { desc = 'Move selection up' })

-- Keep the selection when indenting in visual mode
map('v', '<', '<gv')
map('v', '>', '>gv')

-- Buffers (open files) -------------------------------------------------------
map('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next buffer' })
map('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Previous buffer' })
map('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = 'Close buffer' })

-- Find (fzf-lua) ---------------------------------------------------------------
map('n', '<leader>ff', '<cmd>FzfLua files<cr>', { desc = 'Find files' })
map('n', '<leader>fg', '<cmd>FzfLua live_grep<cr>', { desc = 'Search text in project' })
map('n', '<leader>fb', '<cmd>FzfLua buffers<cr>', { desc = 'Open buffers' })
map('n', '<leader>fr', '<cmd>FzfLua oldfiles<cr>', { desc = 'Recent files' })
map('n', '<leader>fh', '<cmd>FzfLua helptags<cr>', { desc = 'Help pages' })
map('n', '<leader>fk', '<cmd>FzfLua keymaps<cr>', { desc = 'Keymaps' })
map('n', '<leader>fd', '<cmd>FzfLua diagnostics_workspace<cr>', { desc = 'Diagnostics (project)' })
map('n', '<leader>fs', '<cmd>FzfLua lsp_document_symbols<cr>', { desc = 'Symbols in this file' })
map('n', '<leader>fS', '<cmd>FzfLua lsp_live_workspace_symbols<cr>', { desc = 'Symbols in project' })

-- File explorer (oil): `-` opens the folder of the current file ----------------
map('n', '-', '<cmd>Oil<cr>', { desc = 'Open parent folder' })

-- Formatting -------------------------------------------------------------------
map({ 'n', 'x' }, '<leader>cf', function()
  require('conform').format({ lsp_format = 'fallback' })
end, { desc = 'Format file' })

map('n', '<leader>uf', function()
  vim.g.autoformat = not (vim.g.autoformat ~= false)
  vim.notify('Format on save: ' .. (vim.g.autoformat and 'ON' or 'OFF'))
end, { desc = 'Toggle format on save' })

-- Terminal ---------------------------------------------------------------------
map('n', '<leader>tt', '<cmd>botright 15split | terminal<cr>', { desc = 'Open terminal' })
map('t', '<Esc><Esc>', [[<C-\><C-n>]], { desc = 'Leave terminal mode' })
vim.api.nvim_create_autocmd('TermOpen', {
  callback = function()
    vim.cmd.startinsert()   -- start typing right away
  end,
})
