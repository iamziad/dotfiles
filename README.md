# dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level
directory is a stow package whose contents mirror `$HOME`.

| Package        | Target in `$HOME`                                   |
| -------------- | --------------------------------------------------- |
| `emacs`        | `.config/emacs`                                     |
| `vim`          | `.config/vim`                                       |
| `clang-format` | `.clang-format`                                     |
| `fish`         | `.config/fish`                                      |
| `tmux`         | `.config/tmux`                                      |
| `git`          | `.config/git`                                       |
| `i3`           | `.config/i3` (incl. i3blocks scripts)               |
| `picom`        | `.config/picom`                                     |
| `dunst`        | `.config/dunst`                                     |
| `alacritty`    | `.config/alacritty`                                 |
| `xsettingsd`   | `.config/xsettingsd`                                |
| `redshift`     | `.config/redshift.conf`                             |
| `mimeapps`     | `.config/mimeapps.list`                             |
| `gtk`          | `.config/gtk-3.0`, `.config/gtk-4.0`                |
| `xorg`         | `.Xresources`, `.xprofile`                          |
| `applications` | `.local/share/applications/*.desktop`               |
| `scripts`      | `.local/bin/my-*`                                   |

```sh
./deploy.sh              # stow all packages
./deploy.sh fish git     # only some
stow -D -t ~ i3          # unlink one package
```

All personal scripts are prefixed with `my-` (e.g. `my-screenshot`).
