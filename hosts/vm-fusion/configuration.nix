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
