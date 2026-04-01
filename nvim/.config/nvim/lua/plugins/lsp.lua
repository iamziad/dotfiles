-- ============================================================================
-- Neovim LSP, Linting, Formatting & Completion Configuration
-- ============================================================================

-- ==========================
-- 1. Setup Mason (LSP Installer)
-- ==========================
require("mason").setup({})

-- ==========================
-- 2. Diagnostic Signs & Configuration
-- ==========================
local diagnostic_signs = {
	Error = " ",
	Warn = " ",
	Hint = "",
	Info = "",
}

vim.diagnostic.config({
	-- virtual_text = { prefix = "●", spacing = 4 },
	virtual_text = nil,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
			[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
			[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
			[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		max_width = 150,
		wrap = true,
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
		focusable = false,
		style = "minimal",
	},
})

-- Floating windows always rounded
do
	local orig = vim.lsp.util.open_floating_preview
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or "rounded"
		return orig(contents, syntax, opts, ...)
	end
end

-- ==========================
-- 3. LSP Keymaps & Attach Function
-- ==========================
local function lsp_on_attach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if not client then
		return
	end

	local bufnr = ev.buf
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- LSP Navigation
	vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts, { desc = "Goto Definition" })
	vim.keymap.set("n", "<leader>gS", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, opts, { desc = "Goto Definition Split" })
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

	-- Code actions
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts, { desc = "Code Action" })
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts, { desc = "Rename" })

	-- Diagnostics
	vim.keymap.set("n", "<leader>D", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, opts, { desc = "Line Diagnostics" })
	vim.keymap.set("n", "<leader>d", function()
		vim.diagnostic.open_float({ scope = "cursor" })
	end, opts, { desc = "Cursor Diagnostics" })
	vim.keymap.set("n", "<leader>nd", function()
		vim.diagnostic.jump({ count = 1 })
	end, opts)
	vim.keymap.set("n", "<leader>pd", function()
		vim.diagnostic.jump({ count = -1 })
	end, opts)

	-- FZF integration
	vim.keymap.set("n", "<leader>fr", function()
		require("fzf-lua").lsp_references()
	end, opts, { desc = "Show References" })
	vim.keymap.set("n", "<leader>ft", function()
		require("fzf-lua").lsp_typedefs()
	end, opts, { desc = "Go to Type" })
	vim.keymap.set("n", "<leader>fs", function()
		require("fzf-lua").lsp_document_symbols()
	end, opts)
	vim.keymap.set("n", "<leader>fw", function()
		require("fzf-lua").lsp_workspace_symbols()
	end, opts)
	vim.keymap.set("n", "<leader>fi", function()
		require("fzf-lua").lsp_implementations()
	end, opts)

	-- Organize Imports + Format
	if client:supports_method("textDocument/codeAction", bufnr) then
		vim.keymap.set("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true,
				bufnr = bufnr,
			})
			vim.defer_fn(function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end, 50)
		end, opts)
	end
end

-- Autocmd for attaching LSP
local augroup = vim.api.nvim_create_augroup("LspConfig", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

-- ==========================
-- 4. Diagnostic Keymaps
-- ==========================
vim.keymap.set("n", "<leader>xl", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open Diagnostic List" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show Line Diagnostics" })

-- ==========================
-- 5. Completion Setup (blink.cmp)
-- ==========================
require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "hide" },
		["<CR>"] = { "accept", "fallback" },
		["<C-j>"] = { "select_next", "fallback" },
		["<C-k>"] = { "select_prev", "fallback" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},
	appearance = { nerd_font_variant = "mono" },
	completion = { menu = { auto_show = true } },
	sources = { default = { "lsp", "path", "buffer", "snippets" } },
	snippets = {
		expand = function(snippet)
			require("luasnip").lsp_expand(snippet)
		end,
	},
	fuzzy = { implementation = "prefer_rust", prebuilt_binaries = { download = true } },
})

-- Apply capabilities to all servers
vim.lsp.config["*"] = { capabilities = require("blink.cmp").get_lsp_capabilities() }

-- ==========================
-- 6. LSP Server Configurations
-- ==========================
vim.lsp.config("lua_ls", {
	settings = { Lua = { diagnostics = { globals = { "vim" } }, telemetry = { enable = false } } },
})
vim.lsp.config("basedpyright", {})
vim.lsp.config("bashls", {})
vim.lsp.config("ts_ls", {})
vim.lsp.config("gopls", {})

-- clangd handles ONLY C++ and headers, excludes C files
vim.lsp.config("clangd", {
	-- filetypes = { "cpp", "hpp", "cxx", "hxx" },
})

-- ==========================
-- 7. EFM (Formatting & Linting) Setup
-- ==========================
-- Explicitly require linters & formatters
local luacheck = require("efmls-configs.linters.luacheck")
local stylua = require("efmls-configs.formatters.stylua")
local flake8 = require("efmls-configs.linters.flake8")
local black = require("efmls-configs.formatters.black")
local prettier = require("efmls-configs.formatters.prettier")
local eslint_d = require("efmls-configs.linters.eslint_d")
local fixjson = require("efmls-configs.formatters.fixjson")
local shellcheck = require("efmls-configs.linters.shellcheck")
local shfmt = require("efmls-configs.formatters.shfmt")
local cpplint = require("efmls-configs.linters.cpplint")
local clangfmt = require("efmls-configs.formatters.clang_format")
local go_revive = require("efmls-configs.linters.go_revive")
local gofumpt = require("efmls-configs.formatters.gofumpt")

clangfmt.formatCommand = "clang-format -style='{BasedOnStyle: llvm, IndentWidth: 4, TabWidth: 4, UseTab: Never}'"

vim.lsp.config("efm", {
	filetypes = {
		"c",
		"cpp",
		"css",
		"go",
		"html",
		"javascript",
		"javascriptreact",
		"json",
		"jsonc",
		"lua",
		"markdown",
		"python",
		"sh",
		"typescript",
		"typescriptreact",
		"vue",
	},
	init_options = { documentFormatting = true },
	settings = {
		languages = {
			c = { clangfmt }, -- C files handled by efm
			cpp = { clangfmt, cpplint }, -- C++ files
			go = { gofumpt, go_revive },
			css = { prettier },
			html = { prettier },
			javascript = { eslint_d, prettier },
			javascriptreact = { eslint_d, prettier },
			json = { eslint_d, fixjson },
			jsonc = { eslint_d, fixjson },
			lua = { luacheck, stylua },
			markdown = { prettier },
			python = { flake8, black },
			sh = { shellcheck, shfmt },
			typescript = { eslint_d, prettier },
			typescriptreact = { eslint_d, prettier },
			vue = { eslint_d, prettier },
		},
	},
})

-- Enable LSP servers
vim.lsp.enable({ "lua_ls", "basedpyright", "bashls", "ts_ls", "clangd", "efm" })

-- ==========================
-- 8. Auto Format on Save
-- ==========================
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	pattern = {
		"*.lua",
		"*.py",
		"*.go",
		"*.js",
		"*.jsx",
		"*.ts",
		"*.tsx",
		"*.json",
		"*.css",
		"*.scss",
		"*.html",
		"*.sh",
		"*.bash",
		"*.zsh",
		"*.c",
		"*.cpp",
		"*.h",
		"*.hpp",
	},
	callback = function(args)
		local buf = args.buf
		local bo = vim.bo[buf]

		if bo.buftype ~= "" or not bo.modifiable or vim.api.nvim_buf_get_name(buf) == "" then
			return
		end

		local has_efm = false
		for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
			if c.name == "efm" then
				has_efm = true
				break
			end
		end
		if not has_efm then
			return
		end

		pcall(vim.lsp.buf.format, {
			bufnr = buf,
			timeout_ms = 2000,
			filter = function(c)
				return c.name == "efm"
			end,
		})
	end,
})

-- ==========================
-- 9. Utility Keymap: List attached LSP clients
-- ==========================
vim.keymap.set("n", "<leader>lc", function()
	for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
		print(client.name)
	end
end, { desc = "List LSP Clients" })
