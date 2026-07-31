{ pkgs, ... }:

{
  hardware.bluetooth.enable = true;

  # --- Packages ---

  environment.systemPackages = with pkgs; [
    bluetui
  ];
}
