{ username, ... }:

{
  imports = [
    ../modules/base.nix
    ../modules/console.nix
    ../modules/desktop.nix
    ../modules/development.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${username} = import (../users + "/${username}/home.nix");
  };
}
