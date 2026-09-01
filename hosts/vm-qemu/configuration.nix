_:

let
  disk = "/dev/vda";
in

{
  imports = [
    (import ../common/disko-vm.nix { inherit disk; })
    ./hardware-configuration.nix

    ../../profiles/workstation.nix
  ];

  networking.hostName = "vm-qemu";
  system.stateVersion = "26.05";

  services = {
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
    spice-webdavd.enable = true;
  };
}
