{ lib, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  boot.initrd.availableKernelModules = [ "ahci" "ehci_pci" "nvme" "sr_mod" "usbhid" "xhci_pci" ];
}
