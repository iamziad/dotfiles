{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Ziad Ahmed";
        email = "dev.ziadahmed@gmail.com";
      };

      core = {
        editor = "emacsclient -r";
      };

      init = {
        defaultBranch = "main";
      };
    };

    ignores = [
      # --- Vim ---
      "*.swp"
      "*.swo"
      "*~"
      ".netrwhist"
      "undo/"

      # --- Emacs ---
      "\\#*\\#"
      "/.emacs.desktop"
      "/.emacs.desktop.lock"
      ".elc"
      "auto-save-list/"
      "tramp"
      ".\\#*"
    ];
  };
}
