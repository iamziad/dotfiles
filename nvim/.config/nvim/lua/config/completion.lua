-- Autocomplete popup (blink.cmp). Gets its items from the language servers,
-- file paths, snippets and words in the open buffers.
--
-- Keys in the 'super-tab' preset:
--   <Tab>        accept the selected item (or jump to the next snippet field)
--   <S-Tab>      previous snippet field
--   <C-n>/<C-p>  next / previous item        (or <Down>/<Up>)
--   <C-Space>    open the menu manually / toggle documentation
--   <C-e>        close the menu
require('blink.cmp').setup({
  keymap = { preset = 'super-tab' },

  appearance = { nerd_font_variant = 'mono' },

  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 300 },
  },

  signature = { enabled = true },   -- show function parameters while typing

  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },

  -- If the fast prebuilt matcher can't be downloaded, fall back to Lua with a warning.
  fuzzy = { implementation = 'prefer_rust_with_warning' },
})
