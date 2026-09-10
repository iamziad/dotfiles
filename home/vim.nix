{ pkgs,  ... }:

{
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      gruvbox
    ];
    extraConfig = ''
      source ~/.config/vim/vimrc
    '';
  };
}
