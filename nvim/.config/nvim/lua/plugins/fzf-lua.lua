require("fzf-lua").setup({
	winopts = {
		height = 0.75,
		width = 0.75,
		row = 1,
		col = 0,
		border = "none",
		preview = {
			hidden = "start",
			layout = "horizontal",
			horizontal = "right:65%",
			border = "none",
			winopts = {
				-- This adds a slight highlight difference to the preview
				winhighlight = "Normal:NormalSB,FloatBorder:FloatBorder",
			},
		},
	},
	fzf_opts = {
		["--layout"] = "reverse-list",
	},
	keymap = {
		builtin = {
			["<C-p>"] = "toggle-preview",
		},
		fzf = {
			["ctrl-p"] = "toggle-preview",
		},
	},
})

local fzf = require("fzf-lua")
vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "FZF Files" })
vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "FZF Live Grep" })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "FZF Buffers" })
vim.keymap.set("n", "<leader>fh", fzf.help_tags, { desc = "FZF Help Tags" })

vim.keymap.set("n", "<leader>fx", fzf.diagnostics_document, { desc = "FZF Diagnostics Document" })
vim.keymap.set("n", "<leader>fX", fzf.diagnostics_workspace, { desc = "FZF Diagnostics Workspace" })

-- === Git Integration ===
vim.keymap.set("n", "<leader>gs", fzf.git_status, { desc = "Git Status" })
vim.keymap.set("n", "<leader>gc", fzf.git_commits, { desc = "Git Commits" })
vim.keymap.set("n", "<leader>gC", fzf.git_bcommits, { desc = "Git Buffer Commits" })
vim.keymap.set("n", "<leader>gb", fzf.git_branches, { desc = "Git Branches" })
vim.keymap.set("n", "<leader>gz", fzf.git_stash, { desc = "Git Stash" })

vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "FZF Keymaps" })
