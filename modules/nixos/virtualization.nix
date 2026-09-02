{
  pkgs,
  username,
  ...
}:

{
  virtualisation = {
    docker.enable = true;

    libvirtd = {
      enable = true;
      qemu.package = pkgs.qemu_kvm;
    };
  };

  users.users.${username}.extraGroups = [
    "docker"
    "libvirtd"
  ];
}
