{
  pkgs,
  username,
  ...
}:

{
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;

  users.users.${username}.extraGroups = [
    "docker"
    "libvirtd"
  ];

  # --- Packages ---

  environment.systemPackages = with pkgs; [
    gnome-boxes
    qemu_kvm
  ];
}
