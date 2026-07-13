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

  system.stateVersion = "26.05";

  networking.hostName = "VSNixOSTP";

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
}
