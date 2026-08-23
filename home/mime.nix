{ ... }:

{
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "x-scheme-handler/http"  = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "text/html"              = "firefox.desktop";
      "application/pdf"        = "firefox.desktop";

      "image/jpeg"    = "feh.desktop";
      "image/png"     = "feh.desktop";
      "image/webp"    = "feh.desktop";
      "image/bmp"     = "feh.desktop";
      "image/tiff"    = "feh.desktop";
      "image/svg+xml" = "feh.desktop";

      "video/mp4"        = "mpv.desktop";
      "video/mpeg-4"     = "mpv.desktop";
      "video/mkv"        = "mpv.desktop";
      "video/webm"       = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/avi"        = "mpv.desktop";
      "video/quicktime"  = "mpv.desktop";
      "video/x-flv"      = "mpv.desktop";

      "text/plain"         = "emacsclient.desktop";
      "text/x-csrc"        = "emacsclient.desktop";
      "text/x-python"      = "emacsclient.desktop";
      "text/x-java"        = "emacsclient.desktop";
      "text/x-shellscript" = "emacsclient.desktop";
      "text/css"           = "emacsclient.desktop";
      "text/x-makefile"    = "emacsclient.desktop";
    };

    associations.added = {
      "text/plain" = "emacsclient.desktop";
    };
  };
}
