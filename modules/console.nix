{ pkgs, pkgsUnstable, ... }:

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
