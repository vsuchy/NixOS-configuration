_:

{
  imports = [
    ../common/disko-vm.nix
    ./hardware-configuration.nix

    ../../profiles/workstation.nix
  ];

  disko.devices.disk.main.device = "/dev/vda";

  networking.hostName = "vm-qemu";
  system.stateVersion = "26.05";

  # --- Boot ---

  boot.loader = {
    efi.canTouchEfiVariables = true;

    systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
  };

  # --- Guest tools ---

  services = {
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
    spice-webdavd.enable = true;
  };
}
