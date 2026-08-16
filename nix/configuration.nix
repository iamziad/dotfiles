{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix = {
    settings = {
      auto-optimise-store = true;
    };

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
  # Boot
  # ---------------------------------------------------------------------

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };

  boot.loader.efi.efiSysMountPoint = "/efi/boot";

  # ---------------------------------------------------------------------
  # Networking
  # ---------------------------------------------------------------------

  networking.hostName = "nixpc";
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # ---------------------------------------------------------------------
  # Hardware
  # ---------------------------------------------------------------------

  hardware = {
    i2c.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };

  fileSystems."/mnt/hdd" = {
    device  = "/dev/disk/by-uuid/7E6F-FB0D";
    fsType  = "exfat";
    options = [ "defaults" "nofail" "x-systemd.automount" ];
  };

  # ---------------------------------------------------------------------
  # Users
  # ---------------------------------------------------------------------

  users.users.ziad = {
    isNormalUser = true;
    extraGroups = [ "wheel" "i2c" ];
    shell = pkgs.fish;
  };

  programs = {
    fish.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  # ---------------------------------------------------------------------
  # GUI
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
        gnome-themes-extra
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
    stow
    git
    github-cli
    cloudflare-warp
    fish
    tmux
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
    dunst.enable = true;
    picom.enable = true;
    emacs.enable = true;


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

  # polkit authentication agent for the graphical session
  # systemd.user.services.polkit-gnome-authentication-agent-1 = {
    #   description = "polkit-gnome-authentication-agent-1";
    #   wantedBy = [ "graphical-session.target" ];
    #   wants = [ "graphical-session.target" ];
    #   after = [ "graphical-session.target" ];
    #   serviceConfig = {
      #     Type = "simple";
      #     ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      #     Restart = "on-failure";
      #     RestartSec = 1;
      #     TimeoutStopSec = 10;
      #   };
      # };

      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # programs.mtr.enable = true;
      # programs.gnupg.agent = {
        #   enable = true;
        #   enableSSHSupport = true;
        # };

        # ---------------------------------------------------------------------
        # State Version
        # ---------------------------------------------------------------------

        # Do NOT change this value unless you have manually inspected all the
        # changes it would make to your configuration, and migrated your data
        # accordingly. See `man configuration.nix` or
        # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
        system.stateVersion = "26.05"; # Did you read the comment?
}
