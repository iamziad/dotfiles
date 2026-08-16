{ config, pkgs, lib, ... }:

{
  programs.tmux = {
    enable = true;
    keyMode = "emacs";
    mouse = true;
    escapeTime = 0;
    focusEvents = true;
    shortcut = "Space";
    terminal = "screen-256color";

    extraConfig = ''
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -as terminal-features ",xterm-256color:clipboard"
      set -as terminal-features ",alacritty:clipboard"
      set -g status-keys emacs
      set -s set-clipboard on
      set-option -g bell-action none
      set-option -g visual-bell off
      set -g default-command "''${SHELL}"

      bind % split-window -h -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"

      bind -n M-h previous-window
      bind -n M-l next-window
      bind -n M-0 select-window -t 0
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind -n C-h send-keys C-h
      bind -n C-j send-keys C-j
      bind -n C-k send-keys C-k
      bind -n C-l send-keys C-l

      # default statusbar colors
      set-option -g status-style "fg=#bdae93,bg=#3c3836"

      # default window title colors
      set-window-option -g window-status-style "fg=#bdae93,bg=default"

      # active window title colors
      set-window-option -g window-status-current-style "fg=#fabd2f,bg=default"

      # pane border
      set-option -g pane-border-style "fg=#3c3836"
      set-option -g pane-active-border-style "fg=#504945"
      set -g pane-border-lines heavy

      # message text
      set-option -g message-style "fg=#d5c4a1,bg=#3c3836"

      # pane number display
      set-option -g display-panes-active-colour "#b8bb26"
      set-option -g display-panes-colour "#fabd2f"

      # clock
      set-window-option -g clock-mode-colour "#b8bb26"

      # copy mode highlight
      set-window-option -g mode-style "fg=#bdae93,bg=#504945"

      # bell
      set-window-option -g window-status-bell-style "fg=#3c3836,bg=#fb4934"
    '';
  };
}
