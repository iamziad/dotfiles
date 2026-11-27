-- Formatting with conform.nvim. It runs an external formatter on the buffer.
-- Formatters are installed by Mason (see lsp.lua). If a filetype has no formatter
-- here, conform falls back to the language server's own formatting.

require('conform').setup({
  formatters_by_ft = {
    javascript = { 'prettier' },
    javascriptreact = { 'prettier' },
    typescript = { 'prettier' },
    typescriptreact = { 'prettier' },
    html = { 'prettier' },
    htmlangular = { 'prettier' },   -- Angular templates
    css = { 'prettier' },
    scss = { 'prettier' },
    json = { 'prettier' },
    jsonc = { 'prettier' },
    yaml = { 'prettier' },
    markdown = { 'prettier' },
    java = { 'google-java-format' },
    lua = { 'stylua' },
  },

  formatters = {
    -- `--aosp` = Google Java Format with 4-space indentation instead of 2.
    ['google-java-format'] = { prepend_args = { '--aosp' } },
  },

  -- Format when you save. Turn it off / on with <leader>uf.
  format_on_save = function()
    if vim.g.autoformat == false then
      return
    end
    return { timeout_ms = 3000, lsp_format = 'fallback' }
  end,
})
