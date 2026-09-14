" This is symlinked to ~/.vimrc by arch/install.sh.
" Equivalent to home/vim.nix: load the gruvbox plugin (installed as a
" native vim8 package, no plugin manager) then source the real config.
packloadall
source ~/.config/vim/vimrc
