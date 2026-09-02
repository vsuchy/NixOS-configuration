{
  pkgs,
  ...
}:

let
  disk = "/dev/nvme0n1";
in

{
  imports = [
    (import ./disko.nix { inherit disk; })
    ./hardware-configuration.nix

    ../../profiles/workstation.nix
    ../../modules/nixos/tailscale.nix
    ../../modules/nixos/virtualization.nix
  ];

  networking.hostName = "thinkpad-p14s";
  system.stateVersion = "26.05";

  hardware = {
    bluetooth.enable = true;
    enableRedistributableFirmware = true;
  };

  # --- Boot ---

  environment.systemPackages = with pkgs; [
    sbctl
  ];

  boot = {
    initrd.systemd.enable = true;

    loader.efi.canTouchEfiVariables = true;

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
