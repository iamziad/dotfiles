# dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level
directory is a stow package whose contents mirror `$HOME`.

| Package   | Contents                                               |
| --------- | ------------------------------------------------------ |
| `shell`   | fish, tmux                                             |
| `editors` | emacs, vim, clang-format                               |
| `git`     | git config and global ignore                           |
| `desktop` | i3, picom, dunst, redshift, xsettingsd, .Xresources, .xprofile |
| `gui`     | alacritty, GTK settings, mimeapps, .desktop entries    |
| `scripts` | `my-*` scripts + `scripts.nix` (installed via Nix, **not** stowed) |

```sh
./deploy.sh            # stow all packages
./deploy.sh shell git  # only some
stow -D -t ~ gui       # unlink one package
```

All personal scripts are prefixed with `my-` (e.g. `my-screenshot`).
