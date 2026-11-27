-- Treesitter = a real parser for your code. Gives accurate highlighting and folding.
-- This is the new `main` branch of nvim-treesitter: it only installs parsers.
-- Highlighting itself is started by Neovim (vim.treesitter.start), see the autocmd below.
-- Needs: the `tree-sitter` CLI and a C compiler (gcc) to build the parsers.

local parsers = {
  -- the languages you asked for
  'java', 'javascript', 'typescript', 'tsx', 'html', 'css', 'scss', 'angular',
  -- config / misc
  'json', 'yaml', 'bash', 'markdown', 'markdown_inline', 'regex',
  -- for editing this config
  'lua', 'vim', 'vimdoc', 'query',
}

-- Installs the ones that are missing (runs in the background, skips existing ones).
require('nvim-treesitter').install(parsers)

-- Angular templates (*.component.html) have the filetype `htmlangular`
-- and should use the `angular` parser.
vim.treesitter.language.register('angular', 'htmlangular')
-- .jsonc files (tsconfig.json etc.) are parsed with the json parser.
vim.treesitter.language.register('json', 'jsonc')

-- Turn on treesitter highlighting for every filetype that has a parser.
-- pcall = "try, and ignore the error if there is no parser for this filetype".
vim.api.nvim_create_autocmd('FileType', {
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})
