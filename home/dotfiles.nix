{ config, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  sym = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  home.file = {
    ".clang-format".source = sym "config/clang-format";
  };

  xdg.configFile = {
    "emacs".source     = sym "config/emacs";
    "vim/vimrc".source = sym "config/vim/vimrc";
    "i3".source        = sym "config/i3"; # WM
    "alacritty".source = sym "config/alacritty";
  };

  xdg.dataFile."applications/feh.desktop".source = sym "config/feh.desktop";
}
