# Neovim config: Java / JS / TS / React / Angular / Tailwind

Small, commented config for **Neovim 0.12+**. Tested on Neovim 0.12.6.
No plugin manager to install (uses the built-in `vim.pack`), no `nvim-lspconfig` boilerplate
(uses the built-in `vim.lsp.config` / `vim.lsp.enable`).

## 1. Install the tools (Arch Linux)

```sh
sudo pacman -S --needed neovim git base-devel ripgrep fd fzf nodejs npm \
    unzip curl wget python tree-sitter-cli xclip jdk-openjdk
nvim --version   # must say 0.12 or newer
```

* `base-devel` + `tree-sitter-cli` -> build the syntax parsers
* `ripgrep`, `fd`, `fzf`          -> fuzzy finder
* `nodejs`, `npm`                 -> most language servers + prettier
* `jdk-openjdk`                   -> JDK that runs jdtls (nvim-java reuses the one on your PATH)
* `xclip` (X11) / `wl-clipboard` (Wayland) -> system clipboard
* A **Nerd Font** in your terminal (JetBrainsMono Nerd Font) -> icons

## 2. Put the config in place

```sh
mv ~/.config/nvim ~/.config/nvim.bak        # only if you already have one
cp -r .config/nvim ~/.config/nvim           # or: stow nvim   (this folder is laid out for GNU Stow)
nvim
```

First launch: plugins are cloned, parsers are built, language servers are downloaded
(Mason, in the background). Give it a minute, then **restart nvim once**.
Watch progress with `:Mason`. The first launch after adding Java support, nvim-java
also downloads jdtls, the debugger, the test runner and Spring Boot tools
(watch the notifications). It reuses the JDK on your PATH.

## 3. Files

```
init.lua                 load order (leader key is Space)
lua/config/options.lua   editor settings
lua/config/plugins.lua   every plugin, in one list
lua/config/ui.lua        theme, statusline, which-key, fzf, oil, gitsigns, small helpers
lua/config/treesitter.lua syntax highlighting parsers
lua/config/completion.lua autocomplete (blink.cmp)
lua/config/lsp.lua       language servers + LSP shortcuts
lua/config/java.lua      everything Java (nvim-java + jdtls)
lua/config/format.lua    formatters (prettier, google-java-format --aosp, stylua)
lua/config/keymaps.lua   general shortcuts
```

## 4. Language servers

| Server        | For                                   | Starts when                         |
|---------------|---------------------------------------|-------------------------------------|
| jdtls         | Java (installed by nvim-java)         | any .java file                      |
| ts_ls         | JS, TS, JSX, TSX (React)              | any JS/TS file                      |
| eslint        | ESLint diagnostics + fix              | project has an ESLint config        |
| html, cssls   | HTML, CSS/SCSS                        | any such file                       |
| tailwindcss   | Tailwind class completion + hover     | project uses Tailwind               |
| angularls     | Angular templates                     | project has `angular.json`/`nx.json`|
| emmet         | Emmet abbreviations                   | html, css, jsx, tsx                 |
| jsonls, lua_ls| package.json / tsconfig, this config | json, lua                           |

Several servers attach to the same buffer (e.g. a `.tsx` runs ts_ls + eslint + tailwindcss + emmet).
The statusline shows which ones are attached.

## 5. Shortcuts (Space = leader; press Space and wait, which-key lists everything)

| Keys | Action |
|------|--------|
| `K` | hover docs |
| `gd` / `gD` | definition / declaration |
| `grr` `gri` `grt` | references / implementation / type definition |
| `grn` or `<leader>cr` | rename |
| `gra` or `<leader>ca` | code action |
| `]d` `[d` | next / previous diagnostic |
| `<leader>cd` | show diagnostic |
| `<leader>cf` | format file (also on save; `<leader>uf` toggles) |
| `<leader>ce` | ESLint fix all |
| `<leader>uh` | toggle inlay hints |
| `<leader>ff` `fg` `fb` `fr` | files / grep / buffers / recent |
| `<leader>fs` `fS` `fd` | symbols (file / project) / diagnostics |
| `-` | file explorer (oil): edit names, `:w` to apply |
| `<Tab>` | accept completion / next snippet field |
| `<leader>jo` `jv` `jc` `jm` | Java: organize imports / extract variable / constant / method |
| `<leader>ju` | Java: rebuild workspace after changing pom.xml / build.gradle |
| `]h` `[h` `<leader>gp` `gs` `gr` `gb` | git hunks: next, prev, preview, stage, reset, blame |
| `<S-h>` `<S-l>` | previous / next buffer |
| `<C-h/j/k/l>` | move between windows |
| `<leader>tt`, `<Esc><Esc>` | open terminal, leave terminal mode |

## 6. When something does not work

* `:checkhealth vim.lsp`      is the server attached? why not?
* `:lsp`                      manage clients (0.12)
* `:Mason` / `:MasonLog`      server installs
* `:checkhealth nvim-treesitter`
* Java: `~/.local/state/nvim/nvim-java.log`, `:JavaBuildCleanWorkspace` (clears a corrupted index),
  `:JavaDapConfig`, `:JavaRunnerToggleLogs`
* Tailwind not starting: it only starts inside a Tailwind project (config file / dependency).

## 7. Updating

* `:lua vim.pack.update()` -> review the changes, `:write` to accept, `:quit` to cancel.
* Commit `nvim-pack-lock.json` so every machine gets the same plugin versions.
