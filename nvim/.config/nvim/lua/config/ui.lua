-- Theme, statusline and small helper plugins. Each block is independent.

-- Theme: Gruvbox Material --------------------------------------------------
vim.o.background = 'dark'                      -- 'dark' or 'light'
vim.g.gruvbox_material_background = 'medium'   -- 'hard' | 'medium' | 'soft' (contrast)
vim.g.gruvbox_material_foreground = 'material' -- 'material' | 'mix' | 'original'
vim.g.gruvbox_material_enable_italic = 1
vim.g.gruvbox_material_better_performance = 1  -- load highlights faster
vim.g.gruvbox_material_diagnostic_text_highlight = 1
vim.g.gruvbox_material_diagnostic_virtual_text = 'colored'
vim.cmd.colorscheme('gruvbox')

-- Statusline: also shows WHICH language servers are attached to the buffer ---
local function lsp_names()
  local names = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    table.insert(names, client.name)
  end
  return table.concat(names, ' ')
end

require('lualine').setup({
  options = {
    theme = 'gruvbox',
    globalstatus = true,            -- one statusline for all windows
    component_separators = '',
    section_separators = '',
  },
  sections = {
    lualine_x = { lsp_names, 'filetype' },
  },
})

-- which-key: press <Space> and wait a moment -> a popup lists every shortcut.
local wk = require('which-key')
wk.setup({})
wk.add({
  { '<leader>b', group = 'buffer' },
  { '<leader>c', group = 'code' },
  { '<leader>f', group = 'find' },
  { '<leader>g', group = 'git' },
  { '<leader>j', group = 'java' },
  { '<leader>t', group = 'terminal' },
  { '<leader>u', group = 'toggle' },
})

-- fzf-lua: fuzzy finder. Needs the `fzf`, `ripgrep` and `fd` programs installed.
require('fzf-lua').setup({
  fzf_colors = true,   -- use the colors of the current colorscheme
})
require('fzf-lua').register_ui_select()  -- code-action menus etc. also use fzf

-- oil.nvim: open a folder as a buffer. Rename/delete/create files by just editing text, then :w
require('oil').setup({
  view_options = { show_hidden = true },
})

-- gitsigns: shows added/changed/removed lines in the left column.
require('gitsigns').setup({
  on_attach = function(bufnr)
    local gs = require('gitsigns')
    local function map(keys, fn, desc)
      vim.keymap.set('n', keys, fn, { buffer = bufnr, desc = 'Git: ' .. desc })
    end
    map(']h', function() gs.nav_hunk('next') end, 'Next hunk')
    map('[h', function() gs.nav_hunk('prev') end, 'Previous hunk')
    map('<leader>gp', gs.preview_hunk, 'Preview hunk')
    map('<leader>gs', gs.stage_hunk, 'Stage / unstage hunk')
    map('<leader>gr', gs.reset_hunk, 'Reset hunk')
    map('<leader>gb', gs.blame_line, 'Blame line')
  end,
})

-- Small editing helpers (no options needed) ----------------------------------
require('mini.pairs').setup()          -- auto close brackets and quotes
require('nvim-ts-autotag').setup()     -- <div> -> auto adds </div>, renaming a tag renames the pair
require('ts-comments').setup()         -- `gcc` / `gc` pick the right comment style in JSX
