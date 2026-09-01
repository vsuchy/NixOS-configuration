_:

let
  disk = "/dev/nvme0n1";
in

{
  imports = [
    (import ../common/disko-vm.nix { inherit disk; })
    ./hardware-configuration.nix

    ../../profiles/workstation.nix
  ];

  networking.hostName = "vm-fusion";
  system.stateVersion = "26.05";

  virtualisation.vmware.guest.enable = true;
}
