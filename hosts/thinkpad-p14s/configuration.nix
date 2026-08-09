_:

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
}
