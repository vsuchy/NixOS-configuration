{
  nixpkgs-unstable,
  username,
  ...
}:

{
  imports = [
    ../modules/base.nix
    ../modules/desktop.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = {
      inherit nixpkgs-unstable;
    };

    users.${username} = import ../home;
  };
}
