-- local setup_treesitter = function()
-- 	local treesitter = require("nvim-treesitter")
-- 	treesitter.setup({})
-- 	local ensure_installed = {
-- 		"vim",
-- 		"vimdoc",
-- 		"rust",
-- 		"c",
-- 		"cpp",
-- 		"go",
-- 		"html",
-- 		"css",
-- 		"javascript",
-- 		"json",
-- 		"lua",
-- 		"markdown",
-- 		"python",
-- 		"typescript",
-- 		"vue",
--         "tsx",
-- 		"bash",
-- 		"lua",
-- 		"python",
--         "java",
--         "xml",
--         "sql"
-- 	}
--
-- 	local config = require("nvim-treesitter.config")
--
-- 	local already_installed = config.get_installed()
-- 	local parsers_to_install = {}
--
-- 	for _, parser in ipairs(ensure_installed) do
-- 		if not vim.tbl_contains(already_installed, parser) then
-- 			table.insert(parsers_to_install, parser)
-- 		end
-- 	end
--
-- 	if #parsers_to_install > 0 then
-- 		treesitter.install(parsers_to_install)
-- 	end
--
-- 	local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
-- 	vim.api.nvim_create_autocmd("FileType", {
-- 		group = group,
-- 		callback = function(args)
-- 			if vim.list_contains(treesitter.get_installed(), vim.treesitter.language.get_lang(args.match)) then
-- 				vim.treesitter.start(args.buf)
-- 			end
-- 		end,
-- 	})
-- end
--
-- setup_treesitter()

local setup_treesitter = function()
	local treesitter = require("nvim-treesitter")
	treesitter.setup({})

	local ensure_installed = {
		"vim",
		"vimdoc",
		"rust",
		"c",
		"cpp",
		"go",
		"html",
		"css",
		"javascript",
		"json",
		"lua",
		"markdown",
		"python",
		"typescript",
		"vue",
		"tsx",
		"bash",
		"java",
		"xml",
		"sql",
	}

	local parser_install_dir = vim.fn.stdpath("data") .. "/site/parser"
	local parsers_to_install = {}

	for _, parser in ipairs(ensure_installed) do
		local parser_path = parser_install_dir .. "/" .. parser .. ".so"
		if vim.fn.filereadable(parser_path) == 0 then
			table.insert(parsers_to_install, parser)
		end
	end

	if #parsers_to_install > 0 then
		treesitter.install(parsers_to_install)
	end

	local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		callback = function(args)
			local lang = vim.treesitter.language.get_lang(args.match)
			if lang and vim.list_contains(treesitter.get_installed(), lang) then
				vim.treesitter.start(args.buf)
			end
		end,
	})
end

setup_treesitter()
