{ pkgs, pkgsUnstable, ... }:

{
  # --- Packages ---

  environment.systemPackages = with pkgs; [
    ast-grep
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
