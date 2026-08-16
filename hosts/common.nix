{ config, lib, pkgs, ... }:

# Shared NixOS settings for every "i3 desktop" machine. A new host's
# configuration.nix should just `imports = [ ../common.nix ./hardware-configuration.nix ];`
# and then add whatever is genuinely specific to that machine (hostname,
# disks, boot loader quirks, extra hardware).

{
  nix = {
    settings.auto-optimise-store = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    extraOptions = "experimental-features = nix-command flakes";
  };

  time.timeZone = "Africa/Cairo";
  i18n.defaultLocale = "en_US.UTF-8";

  # ---------------------------------------------------------------------
  # Networking
  # ---------------------------------------------------------------------

  networking.networkmanager.enable = true;

  # ---------------------------------------------------------------------
  # Hardware
  # ---------------------------------------------------------------------

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };

  # ---------------------------------------------------------------------
  # Users
  # ---------------------------------------------------------------------

  users.users.ziad = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  programs = {
    fish.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    dconf.enable = true;
  };

  # ---------------------------------------------------------------------
  # GUI (i3 desktop)
  # ---------------------------------------------------------------------

  services.displayManager.ly.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
    nerd-fonts.ubuntu
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];
  fonts.fontconfig.enable = true;

  services.xserver = {
    enable = true;
    xkb = {
      layout = "us,ara";
      options = "grp:win_space_toggle,ctrl:nocaps";
    };

    autoRepeatDelay = 230;
    autoRepeatInterval = 35;
    updateDbusEnvironment = true;

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3blocks
        i3lock-color
        xss-lock
        dunst
        libnotify
        picom
        maim
        xkb-switch
        playerctl
        lxappearance
        redshift
        pcmanfm
        pavucontrol
        lm_sensors
        ddcutil
        polkit_gnome
        feh
        xsettingsd
      ];
    };
  };

  # ---------------------------------------------------------------------
  # Packages
  # ---------------------------------------------------------------------

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    zip
    unzip
    mpv
    firefox
    alacritty
    git
    github-cli
    cloudflare-warp
    fish
    tree
    xclip
    xcolor
    gromit-mpx
    qalculate-gtk
    htop
    xdg-ninja
    emacs
    emacsPackages.vterm
    libvterm
    gcc
    gdb
    valgrind
    gnumake
    clang-tools
    man-pages
    nixd
    bash-language-server
    nodejs
  ];

  documentation = {
    dev.enable = true;
    man.enable = true;
  };

  # ---------------------------------------------------------------------
  # System Services
  # ---------------------------------------------------------------------

  services = {
    dbus.enable = true;
    openssh.enable = true;
    envfs.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
    devmon.enable = true;

    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      jack.enable = true;
    };

    cloudflare-warp = {
      enable = true;
      openFirewall = true;
    };
  };

  security.polkit.enable = true;
}
