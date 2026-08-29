_:

{
  imports = [
    ./modules/cli.nix
    ./modules/desktop.nix
    ./modules/development.nix
  ];

  home.stateVersion = "26.05";

  manual.manpages.enable = false;
}
