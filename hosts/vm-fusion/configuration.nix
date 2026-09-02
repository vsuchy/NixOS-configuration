_:

{
  imports = [
    ../common/disko-vm.nix
    ./hardware-configuration.nix

    ../../profiles/workstation.nix
  ];

  disko.devices.disk.main.device = "/dev/nvme0n1";

  networking.hostName = "vm-fusion";
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

  virtualisation.vmware.guest.enable = true;
}
