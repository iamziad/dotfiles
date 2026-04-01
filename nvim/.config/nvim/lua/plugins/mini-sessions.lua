require("mini.sessions").setup({
	directory = vim.fn.stdpath("data") .. "/sessions",
	autoread = false,
	autowrite = true,
	file = "Session.vim",
})

require("mini.extra").setup()

local map = vim.keymap.set
local sessions = require("mini.sessions")

map("n", "<leader>ss", function()
	sessions.select()
end, { desc = "Pick: Sessions" })

map("n", "<leader>sw", function()
	local name = vim.fn.input("Session name: ")
	if name ~= "" then
		sessions.write(name)
		print("\nSession '" .. name .. "' saved!")
	end
end, { desc = "Session: Save" })

map("n", "<leader>sd", function()
	local latest = sessions.get_latest() or ""
	local name = vim.fn.input("Delete session: ", latest)
	if name ~= "" then
		sessions.delete(name, { force = true })
		print("\nSession '" .. name .. "' deleted.")
	end
end, { desc = "Session: Delete" })
