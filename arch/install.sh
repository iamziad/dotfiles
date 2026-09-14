set -euo pipefail
DOTFILES="$HOME/dotfiles"
cd "$DOTFILES"

link() {
    # link <source under $DOTFILES> <absolute target>
    mkdir -p "$(dirname "$2")"
    ln -sfn "$DOTFILES/$1" "$2"
    echo "linked  $2 -> $1"
}

echo "==> [1/7] Packages"
if command -v pacman >/dev/null; then
    sudo pacman -S --needed - < arch/packages/pacman.txt
else
    echo "pacman not found — is this actually Arch? skipping package install." >&2
fi

if ! command -v yay >/dev/null && ! command -v paru >/dev/null; then
    echo "No AUR helper found. Install yay or paru, then run:"
    echo "  yay -S --needed - < arch/packages/aur.txt"
else
    AUR_HELPER=$(command -v yay || command -v paru)
    "$AUR_HELPER" -S --needed - < arch/packages/aur.txt
fi

echo "==> [2/7] Symlinking dotfiles from ~/dotfiles/config"
link "config/clang-format"            "$HOME/.clang-format"
link "config/emacs"                   "$HOME/.config/emacs"
link "config/vim/vimrc"               "$HOME/.config/vim/vimrc"
link "config/i3"                      "$HOME/.config/i3"
link "config/alacritty"               "$HOME/.config/alacritty"
link "config/dunst/dunstrc"           "$HOME/.config/dunst/dunstrc"
link "config/picom/picom.conf"        "$HOME/.config/picom/picom.conf"
link "config/redshift.conf"           "$HOME/.config/redshift.conf"
link "config/mimeapps.list"           "$HOME/.config/mimeapps.list"
link "config/gtk-3.0/settings.ini"    "$HOME/.config/gtk-3.0/settings.ini"
link "config/gtk-3.0/bookmarks"       "$HOME/.config/gtk-3.0/bookmarks"
link "config/gtk-4.0/settings.ini"    "$HOME/.config/gtk-4.0/settings.ini"
link "config/xsettingsd/xsettingsd.conf" "$HOME/.config/xsettingsd/xsettingsd.conf"
link "config/fish/config.fish"        "$HOME/.config/fish/config.fish"
link "config/tmux/tmux.conf"          "$HOME/.config/tmux/tmux.conf"
link "config/feh.desktop"             "$HOME/.local/share/applications/feh.desktop"
link "config/applications/emacsclient.desktop" "$HOME/.local/share/applications/emacsclient.desktop"
link "config/git/config"              "$HOME/.config/git/config"
link "config/git/ignore"              "$HOME/.config/git/ignore"
link "config/Xresources"              "$HOME/.Xresources"
link "config/xprofile"                "$HOME/.xprofile"
link "config/vim/entry.vimrc"         "$HOME/.config/vim/vimrc"

echo "==> [3/7] Scripts -> ~/.local/bin (same names scripts.nix used to wrap)"
mkdir -p "$HOME/.local/bin"
declare -A SCRIPTS=(
    [toggle-darkmode.sh]=my-toggle-darkmode
    [screenshot.sh]=my-screenshot
    [screenlayout.sh]=my-screenlayout
    [feh.sh]=my-random-wallpaper
    [brightness.sh]=my-brightness
    [i3lock.sh]=my-i3lock
    [xautolock.sh]=my-xautolock
    [suspend_notify.sh]=my-suspend-notify
)
for src in "${!SCRIPTS[@]}"; do
    ln -sfn "$DOTFILES/home/scripts/$src" "$HOME/.local/bin/${SCRIPTS[$src]}"
done
echo "note: config/i3/config also execs ~/.screenlayout/dual.sh — that was an"
echo "      arandr-generated file, never part of this repo. Recreate it with"
echo "      arandr, or write your own xrandr script for HDMI-1 (\$pri) + DP-1 (\$sec)."


echo "==> [6/7] Hardware bits (i2c for ddcutil, zram)"
sudo usermod -aG i2c "$USER"
echo i2c-dev | sudo tee /etc/modules-load.d/i2c-dev.conf >/dev/null

sudo tee -a /etc/environment >/dev/null <<'EOF'
XDG_CONFIG_HOME=/home/USERNAME/.config
XDG_DATA_HOME=/home/USERNAME/.local/share
XDG_CACHE_HOME=/home/USERNAME/.cache
XDG_STATE_HOME=/home/USERNAME/.local/state
EDITOR=emacsclient
TERMINAL=alacritty
EOF
sudo sed -i "s#/home/USERNAME#$HOME#g" /etc/environment

cat <<'EOF'

Done. A few things this script deliberately does NOT do for you —
handle these once, manually:

  - /mnt/hdd exfat mount: the old fstab entry pointed at a specific
    disk UUID (7E6F-FB0D) from the NixOS machine. Run `sudo blkid` on
    THIS machine's drive and add your own line to /etc/fstab.
EOF
