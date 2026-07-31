{ pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;

  users.users.vs.extraGroups = [ "libvirtd" ];

  # --- Packages ---

  environment.systemPackages = with pkgs; [
    gnome-boxes
    qemu_kvm
  ];
}
