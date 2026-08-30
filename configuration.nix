{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix

    # ./desktop/i3.nix
    ./desktop/kde.nix
  ];

  networking.hostName = "nixpc";

  # ---------------------------------------------------------------------
  # Boot
  # ---------------------------------------------------------------------

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true; # dual-boot with Windows on /dev/sdb
  };

  boot.loader.efi.efiSysMountPoint = "/efi/boot";

  # ---------------------------------------------------------------------
  # Nix
  # ---------------------------------------------------------------------

  nix = {
    settings.auto-optimise-store = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
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

  hardware.i2c.enable = true; # needed for ddcutil monitor brightness control

  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };

  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/7E6F-FB0D";
    fsType = "exfat";
    options = [
      "defaults"
      "nofail"
      "x-systemd.automount"
    ];
  };

  # ---------------------------------------------------------------------
  # Users
  # ---------------------------------------------------------------------

  users.users.ziad = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "i2c"
    ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  # ---------------------------------------------------------------------
  # GUI
  # ---------------------------------------------------------------------

  services.displayManager.ly.enable = true;
  programs.dconf.enable = true;

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
    tree
    mpv
    firefox
    google-chrome
    alacritty
    git
    github-cli
    cloudflare-warp
    fish
    xclip
    xcolor
    gromit-mpx
    qalculate-gtk
    htop
    btop
    emacs
    emacsPackages.vterm
    libvterm
    gcc
    gdb
    valgrind
    gnumake
    clang-tools
    man-pages
    nil
    bash-language-server
    yt-dlp
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

  # ---------------------------------------------------------------------
  # State Version — do NOT change this after install. See
  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  # ---------------------------------------------------------------------

  system.stateVersion = "26.05";
}
