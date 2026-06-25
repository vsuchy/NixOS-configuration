let
  host = {
    platform = "x86_64-linux";
    disk = "/dev/nvme0n1";
    hostname = "VSThinkPad";
    username = "vs";
    userFullName = "Vlad Suchy";
  };
in

{
  inherit host;

  module = { inputs, ... }: {
    imports = [
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen6

      ./disko.nix
      ./hardware-configuration.nix

      ../../modules/base.nix
      ../../modules/desktop.nix
    ];

    system.stateVersion = "26.05";

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inherit host; };

    home-manager.users = {
      ${host.username} = import (../../users + "/${host.username}/home.nix");
    };
  };
}
