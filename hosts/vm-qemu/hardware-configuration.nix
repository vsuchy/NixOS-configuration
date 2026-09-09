{
  lib,
  ...
}:

{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  boot.initrd.availableKernelModules = [
    "ahci"
    "sd_mod"
    "sr_mod"
    "virtio_blk"
    "virtio_pci"
    "virtio_scsi"
    "xhci_pci"
  ];
}
