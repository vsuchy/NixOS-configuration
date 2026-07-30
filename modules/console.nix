{ pkgs, nixpkgs-unstable, ... }:

let
  pkgsUnstable = nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in

{
  # --- Packages ---

  environment.systemPackages = with pkgs; [
    ast-grep
    libnotify
    ripgrep
    unzip
    wget
    zip

    fastfetch
    git
    vifm
    vim

    pkgsUnstable.codex
  ];
}
