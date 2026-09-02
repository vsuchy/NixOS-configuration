{
  nixpkgs-unstable,
  username,
  ...
}:

{
  imports = [
    ../modules/nixos/base.nix
    ../modules/nixos/desktop.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = {
      inherit nixpkgs-unstable;
    };

    users.${username} = import ../modules/home-manager;
  };
}
