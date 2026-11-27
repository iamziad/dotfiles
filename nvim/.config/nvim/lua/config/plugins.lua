-- The list of ALL plugins, in one place.
-- Neovim 0.12 has a built-in plugin manager called `vim.pack`:
--   * first launch  -> it clones every plugin below with git
--   * :lua vim.pack.update()  -> review and update plugins (":write" to accept, ":quit" to cancel)
--   * nvim-pack-lock.json     -> remembers the exact commit of every plugin (commit it to git)

local function gh(repo)
  return 'https://github.com/' .. repo
end

-- nvim-treesitter needs to rebuild its parsers after an update.
-- This autocmd MUST be defined before vim.pack.add().
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'nvim-treesitter' and kind == 'update' then
      if not ev.data.active then
        vim.cmd.packadd('nvim-treesitter')
      end
      vim.cmd('TSUpdate')
    end
  end,
})

vim.pack.add({
  -- Look & feel
  gh('ellisonleao/gruvbox.nvim'),          -- color scheme
  gh('nvim-tree/nvim-web-devicons'),       -- file icons (needs a Nerd Font in your terminal)
  gh('nvim-lualine/lualine.nvim'),         -- statusline
  gh('folke/which-key.nvim'),              -- popup that shows available shortcuts (great for learning)

  -- Syntax / editing helpers
  { src = gh('nvim-treesitter/nvim-treesitter'), version = 'main' },  -- syntax highlighting
  gh('windwp/nvim-ts-autotag'),            -- auto close/rename HTML + JSX tags
  gh('folke/ts-comments.nvim'),            -- `gc` comments work correctly inside JSX/TSX
  gh('echasnovski/mini.pairs'),            -- auto close ( [ { " '

  -- LSP (language servers)
  gh('neovim/nvim-lspconfig'),             -- ready-made server configs (the lsp/*.lua files)
  gh('mason-org/mason.nvim'),              -- downloads language servers and formatters
  gh('mason-org/mason-lspconfig.nvim'),    -- ensure_installed for language servers
  gh('WhoIsSethDaniel/mason-tool-installer.nvim'), -- ensure_installed for formatters

  -- Java: nvim-java downloads and starts jdtls itself (no Mason package needed),
  -- and adds the extras: class/source navigation, refactors, tests, debugger,
  -- Spring Boot support. These are the plugins it needs.
  { src = gh('JavaHello/spring-boot.nvim'), version = '218c0c26c14d99feca778e4d13f5ec3e8b1b60f' },
  gh('MunifTanjim/nui.nvim'),              -- popup / UI library
  gh('mfussenegger/nvim-dap'),             -- debugger engine (used for tests and `main`)
  gh('nvim-java/nvim-java'),               -- everything Java

  -- Completion
  { src = gh('saghen/blink.cmp'), version = vim.version.range('1.*') },  -- tagged release = prebuilt fast matcher
  gh('rafamadriz/friendly-snippets'),      -- ready-made snippets (React, Java, Angular, ...)

  -- Formatting
  gh('stevearc/conform.nvim'),

  -- Navigation / tools
  gh('ibhagwan/fzf-lua'),                  -- fuzzy finder (files, grep, symbols, ...)
  gh('stevearc/oil.nvim'),                 -- file explorer: edit a folder like a normal buffer (like Emacs dired)
  gh('lewis6991/gitsigns.nvim'),           -- git changes in the sign column
}, { confirm = false })                    -- don't ask for confirmation on first install
