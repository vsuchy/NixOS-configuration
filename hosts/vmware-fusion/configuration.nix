let
  host = {
    platform = "aarch64-linux";
    disk = "/dev/nvme0n1";
    hostname = "VSNixOSVM";
    username = "vs";
    userFullName = "Vlad Suchy";
  };
in

{
  inherit host;

  module = { ... }: {
    imports = [
      ./disko.nix
      ./hardware-configuration.nix

      ../../modules/base.nix
      ../../modules/desktop.nix
    ];

    system.stateVersion = "26.05";

    virtualisation.vmware.guest.enable = true;

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inherit host; };

    home-manager.users = {
      ${host.username} = import (../../users + "/${host.username}/home.nix");
    };
  };
}
