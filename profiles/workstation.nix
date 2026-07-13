{ ... }:

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
    users.vs = import ../users/vs/home.nix;
  };
}
