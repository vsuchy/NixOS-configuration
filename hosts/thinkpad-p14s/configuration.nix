{ lib, pkgs, ... }:

let
  disk = "/dev/nvme0n1";
in

{
  imports = [
    (import ./disko.nix { inherit disk; })
    ./hardware-configuration.nix

    ../../profiles/workstation.nix
    ../../modules/bluetooth.nix
    ../../modules/tailscale.nix
    ../../modules/virtualization.nix
  ];

  networking.hostName = "VSNixOSTP";
  system.stateVersion = "26.05";

  hardware.enableRedistributableFirmware = true;

  # --- Boot ---

  environment.systemPackages = with pkgs; [
    sbctl
  ];

  boot = {
    initrd.systemd.enable = true;

    loader.systemd-boot.enable = lib.mkForce false;

    lanzaboote = {
      enable = true;
      configurationLimit = 5;
      pkiBundle = "/var/lib/sbctl";

      measuredBoot = {
        enable = true;
        pcrs = [
          0
          4
          7
        ];
      };
    };
  };
}
