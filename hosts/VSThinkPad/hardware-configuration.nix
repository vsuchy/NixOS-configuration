{ host, lib, ... }:

{
  # Placeholder only.
  #
  # Before the final install, replace this file with the output from:
  #
  #   nixos-generate-config --root /mnt
  #
  # Because Disko owns fileSystems, swapDevices, LUKS mappings, and resume
  # configuration in this repository, keep the generated hardware-specific
  # options but remove generated fileSystems, swapDevices, and duplicate
  # boot.initrd.luks.devices entries unless you intentionally reconcile them.

  nixpkgs.hostPlatform = lib.mkDefault host.platform;

  boot.initrd.availableKernelModules = lib.mkDefault [ "nvme" "sd_mod" "usb_storage" "xhci_pci" ];
  boot.kernelModules = [ "kvm-amd" ];
}
