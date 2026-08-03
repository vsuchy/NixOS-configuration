{
  pkgs,
  username,
  ...
}:

{
  virtualisation.libvirtd.enable = true;

  users.users.${username}.extraGroups = [ "libvirtd" ];

  # --- Packages ---

  environment.systemPackages = with pkgs; [
    gnome-boxes
    qemu_kvm
  ];
}
