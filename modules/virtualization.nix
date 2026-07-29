{ pkgs, ... }:

{
  # --- Packages ---

  environment.systemPackages = with pkgs; [
    gnome-boxes
  ];
}
