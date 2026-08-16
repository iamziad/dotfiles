{ ... }:

{
  services.dunst = {
    enable = true;

    settings = {
      global = {
        monitor = 0;
        follow  = "mouse";

        width  = 340;
        height = 110;
        origin = "top-right";
        offset = "16x16";
        gap_size = 8;

        frame_width = 2;
        frame_color = "#504945";
        corner_radius = 0;

        font = "JetBrainsMono Nerd Font 11";
        line_height = 4;

        padding = 10;
        horizontal_padding = 18;

        icon_position = "left";
        min_icon_size = 32;
        max_icon_size = 96;

        timeout = 2;

        stack_duplicates = true;
        hide_duplicate_count = false;
      };

      urgency_low = {
        background = "#222222";
        foreground = "#ebdbb2";
        timeout = 2;
      };

      urgency_normal = {
        background = "#222222";
        foreground = "#ebdbb2";
        timeout = 2;
      };

      urgency_critical = {
        background = "#222222";
        foreground = "#cc241d";
        timeout = 0;
      };
    };
  };
}
