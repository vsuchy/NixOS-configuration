{ pkgs, config, lib, modulesPath, ... }:

{
  imports = [];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  boot.initrd.kernelModules = [];
  boot.initrd.availableKernelModules = [ "ahci" "ehci_pci" "nvme" "sr_mod" "usbhid" "xhci_pci" ];
  boot.kernelModules = [];
  boot.extraModulePackages = [];
}
