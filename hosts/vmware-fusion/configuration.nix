{ ... }:

let
  disk = "/dev/nvme0n1";
in

{
  imports = [
    (import ./disko.nix { inherit disk; })
    ./hardware-configuration.nix

    ../../profiles/workstation.nix
  ];

  networking.hostName = "VSNixOSVM";
  system.stateVersion = "26.05";

  virtualisation.vmware.guest.enable = true;
}
