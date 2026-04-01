local opt = vim.opt
local cmd = vim.cmd
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
-- ====================================================================
-- Keymaps
-- ====================================================================

map("n", "<leader>ec", "<Cmd>rightbelow vsplit ~/.config/nvim/init.lua<CR>", { desc = "Edit config at right" })

map("i", "kj", "<ESC>")
map("t", "kj", [[<C-\><C-n>]])

-- Netrw
map("n", "<leader>`", vim.cmd.Ex)

-- vscode moving
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- keep cursor in same place when joining lines
map("n", "J", "mzJ`z")

-- resize panes with ctrl
map("n", "<C-Up>", ":resize +2<CR>", { noremap = true, silent = true })
map("n", "<C-Down>", ":resize -2<CR>", { noremap = true, silent = true })
map("n", "<C-Left>", ":vertical resize -2<CR>", { noremap = true, silent = true })
map("n", "<C-Right>", ":vertical resize +2<CR>", { noremap = true, silent = true })

-- Splits
map("n", "<leader>sv", ":vs<CR>", { noremap = true, silent = true })
map("n", "<leader>sh", ":split<CR>", { noremap = true, silent = true })

-- open man pages at right
map("n", "M", function()
	local word = vim.fn.expand("<cword>")
	vim.cmd("vertical rightbelow Man " .. word)
end, { desc = "Open man page vertically" })

-- inline margining without re-selecting
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- cmd :only
map("n", "<leader>o", ":only<CR>", { noremap = true })

-- don't register anything overriden by <leader>p
map("x", "<leader>p", '"_dP')

-- prevent x delete from registering when next paste
vim.keymap.set("n", "x", '"_x', opts)

-- Remap change in normal and visual mode to blackhole
vim.keymap.set("n", "c", '"_c', { noremap = true, silent = true })
vim.keymap.set("v", "c", '"_c', { noremap = true, silent = true })

-- Unmaps Q in normal mode
vim.keymap.set("n", "Q", "<nop>")

-- remember yanked
vim.keymap.set("v", "p", '"_dp', opts)

-- leader d delete wont remember as yanked/clipboard when delete pasting
-- vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- toggle netrw
-- map("n", "<leader>er", ":rightbelow 35vs .<CR>")
-- map("n", "<leader>el", ":35vs .<CR>")

-- teminal buffer
map("n", "<leader>tb", ":bo te<CR>")
map("n", "<leader>tt", ":to te<CR>")
map("n", "<leader>t", ":rightbelow vert te<CR>")
map("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })

-- Navigate between tabs with numbers
for i = 1, 9 do
	map("n", "<leader>" .. i, i .. "gt", { noremap = true, silent = true, desc = "Go to tab " .. i })
end

-- Optional: <leader>0 for tab 10
map("n", "<leader>0", "10gt", { noremap = true, silent = true, desc = "Go to tab 10" })

-- Formating C with clang-format
map("n", "<leader>cf", function()
	vim.cmd("silent !clang-format -i %")
	vim.cmd("e!")
end, { noremap = true, silent = true, desc = "Format with clang-format" })

-- Panes switching
-- vim.keymap.set('n', '<leader>h', '<C-w>h', { desc = 'Move to left pane' })
-- vim.keymap.set('n', '<leader>j', '<C-w>j', { desc = 'Move to bottom pane' })
-- vim.keymap.set('n', '<leader>k', '<C-w>k', { desc = 'Move to top pane' })
-- vim.keymap.set('n', '<leader>l', '<C-w>l', { desc = 'Move to right pane' })

-- Terminal Panes
-- vim.keymap.set('t', '<leader>h', [[<C-\><C-n><C-w>h]], { desc = 'Move to left pane from terminal' })
-- vim.keymap.set('t', '<leader>j', [[<C-\><C-n><C-w>j]], { desc = 'Move to bottom pane from terminal' })
-- vim.keymap.set('t', '<leader>k', [[<C-\><C-n><C-w>k]], { desc = 'Move to top pane from terminal' })
-- vim.keymap.set('t', '<leader>l', [[<C-\><C-n><C-w>l]], { desc = 'Move to right pane from terminal' })
