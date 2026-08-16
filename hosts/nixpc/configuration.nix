{ config, lib, pkgs, ... }:

# Everything that is NOT shared with other hosts lives here: hostname,
# boot/partition layout, this machine's specific hardware (i2c for
# ddcutil monitor control, the exFAT HDD), and the state version this
# machine was first installed with.

{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
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
  # Hardware specific to this box
  # ---------------------------------------------------------------------

  hardware.i2c.enable = true; # needed for ddcutil monitor brightness control
  users.users.ziad.extraGroups = [ "i2c" ];

  fileSystems."/mnt/hdd" = {
    device  = "/dev/disk/by-uuid/7E6F-FB0D";
    fsType  = "exfat";
    options = [ "defaults" "nofail" "x-systemd.automount" ];
  };

  # ---------------------------------------------------------------------
  # State Version
  # ---------------------------------------------------------------------

  # Do NOT copy this value to a new host. Set it to whatever release was
  # current when THAT machine was first installed, then never change it.
  # See `man configuration.nix` or
  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "26.05";
}
