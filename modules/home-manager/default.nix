{ ... }:

{
  imports = [
    ./cli.nix
    ./desktop.nix
    ./development.nix
  ];

  home.stateVersion = "26.05";

  manual.manpages.enable = false;
}
