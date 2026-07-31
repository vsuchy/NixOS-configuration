{ pkgs, ... }:

{
  hardware.bluetooth.enable = true;
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    bluetui
  ];
}
