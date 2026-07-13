{ pkgs, ... }:

{
  # --- Packages ---

  environment.systemPackages = with pkgs; [
    cmake
    gcc
    gnumake
    pkg-config

    nodejs
    ruby
  ];
}
