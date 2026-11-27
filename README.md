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
| `dunst`        | `.config/dunst`                                     |
| `alacritty`    | `.config/alacritty`                                 |
| `mimeapps`     | `.config/mimeapps.list`                             |
| `gtk`          | `.config/gtk-3.0`, `.config/gtk-4.0`                |
| `applications` | `.local/share/applications/*.desktop`               |
| `scripts`      | `.local/bin/my-*` (display-server independent)      |
| `x11`          | everything that only works on X11 (see below)       |

### `x11`

Everything that only works under an X11 session, kept in one package so it can
be dropped when running a Wayland session (`stow -D -t ~ x11`).

| Path in package                                   | What                                       |
| ------------------------------------------------- | ------------------------------------------ |
| `.xprofile`, `.Xresources`                        | X session env + xrdb settings              |
| `.config/i3`                                      | i3, i3blocks (+ its scripts), i3status     |
| `.config/picom`                                   | compositor                                 |
| `.config/redshift`                                | colour temperature (randr)                 |
| `.config/xsettingsd`                              | GTK settings daemon for X                  |
| `.local/bin/my-{xautolock,i3lock,screenlayout}`   | xautolock / i3lock / xrandr                |
| `.local/bin/my-{screenshot,dim-inactive}`         | maim + xclip / xrandr + xdotool            |
| `.local/bin/my-random-wallpaper`                  | `feh --bg-scale`                           |
| `.local/share/applications/feh.desktop`           | feh (X11-only image viewer)                |

```sh
./deploy.sh              # stow all packages
./deploy.sh fish git     # only some
stow -D -t ~ x11         # unlink one package
```

All personal scripts are prefixed with `my-` (e.g. `my-screenshot`).
