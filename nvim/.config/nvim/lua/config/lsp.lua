-- LSP = language servers. They give you completion, go-to-definition, errors,
-- rename, code actions, ... (the same engine VS Code uses).
--
-- How the pieces fit together (Neovim 0.12):
--   mason.nvim        downloads the server programs into ~/.local/share/nvim/mason
--   nvim-lspconfig    ships the ready-made settings for each server (the lsp/*.lua files)
--   vim.lsp.enable()  built into Neovim: "start this server for the matching file types"
--
-- Several servers can be attached to ONE buffer at the same time. That is how
-- React + Tailwind + ESLint all work together in a .tsx file. Nothing to configure.

-- The names below are the nvim-lspconfig names. Mason downloads the matching package.
local servers = {
  -- Java (jdtls) is NOT here: nvim-java installs and starts it itself (see java.lua).
  'ts_ls',                  -- JavaScript / TypeScript / React (JSX, TSX)
  'eslint',                 -- ESLint errors + auto-fix  (only starts in projects that have eslint)
  'html',                   -- HTML
  'cssls',                  -- CSS / SCSS
  'tailwindcss',            -- Tailwind CSS classes completion + hover (only in Tailwind projects)
  'angularls',              -- Angular templates         (only in projects with angular.json)
  'emmet_language_server',  -- Emmet: type `ul>li*3` then accept
  'jsonls',                 -- package.json, tsconfig.json, ...
  'lua_ls',                 -- Lua (for editing this very config)
}

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = servers,
  automatic_enable = false,   -- we enable servers ourselves below, so it is explicit
})

-- Formatters (used by conform.nvim, see format.lua)
require('mason-tool-installer').setup({
  ensure_installed = { 'prettier', 'google-java-format', 'stylua' },
})

-- Settings applied to EVERY server: tell servers that blink.cmp can handle snippets etc.
vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})

-- Per-server tweaks. Everything not mentioned here uses nvim-lspconfig's defaults. ---

-- Lua: know that `vim` is a global.
vim.lsp.config('lua_ls', {
  settings = { Lua = { diagnostics = { globals = { 'vim' } } } },
})

-- CSS: don't warn about Tailwind's @tailwind / @apply / @theme rules.
vim.lsp.config('cssls', {
  settings = {
    css = { lint = { unknownAtRules = 'ignore' } },
    scss = { lint = { unknownAtRules = 'ignore' } },
  },
})

-- Angular: only start inside a real Angular project (a folder with angular.json / nx.json).
-- Without this it would also start on every plain .html / .ts file and crash.
vim.lsp.config('angularls', {
  workspace_required = true,
})

-- Emmet: only where it makes sense (in plain .js/.ts files it just adds noise).
vim.lsp.config('emmet_language_server', {
  filetypes = { 'html', 'htmlangular', 'css', 'scss', 'javascriptreact', 'typescriptreact' },
})

-- Start the servers. They attach automatically when you open a matching file.
vim.lsp.enable(servers)

-- Diagnostics (errors / warnings) look and behaviour ------------------------
vim.diagnostic.config({
  severity_sort = true,                 -- errors first
  virtual_text = { spacing = 2 },       -- message at the end of the line
  float = { source = true },            -- show which server reported the problem
})

-- Shortcuts that exist ONLY in buffers that have a language server -----------
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my-lsp-attach', { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local function map(keys, fn, desc)
      vim.keymap.set('n', keys, fn, { buffer = ev.buf, desc = 'LSP: ' .. desc })
    end

    -- Neovim 0.11+ already gives you these built-in (no config needed):
    --   K     hover documentation          grn   rename
    --   gra   code action                  grr   references
    --   gri   implementation               grt   type definition
    --   gO    symbols of this file         <C-s> (insert mode) signature help
    --   ]d [d next / previous diagnostic   <C-w>d  diagnostic in a float
    -- We only add the classic ones:
    map('gd', vim.lsp.buf.definition, 'Go to definition')
    map('gD', vim.lsp.buf.declaration, 'Go to declaration')
    map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
    map('<leader>cr', vim.lsp.buf.rename, 'Rename symbol')
    map('<leader>cd', vim.diagnostic.open_float, 'Show diagnostic')

    -- Inlay hints (parameter names, inferred types). Off by default, toggle with <leader>uh.
    if client and client:supports_method('textDocument/inlayHint') then
      map('<leader>uh', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
      end, 'Toggle inlay hints')
    end

    -- ESLint: fix everything fixable in the file.
    if client and client.name == 'eslint' then
      map('<leader>ce', '<cmd>LspEslintFixAll<cr>', 'ESLint fix all')
    end

    -- Angular: ts_ls and angularls both offer "rename"; keep only ts_ls's
    -- so you don't get two rename prompts.
    if client and client.name == 'angularls' then
      client.server_capabilities.renameProvider = false
    end
  end,
})
