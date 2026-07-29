{ pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # --- Boot ---

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  boot.kernelParams = [ "quiet" "udev.log_level=3" "rd.systemd.show_status=auto" ];

  boot.plymouth.enable = true;

  # --- Time ---

  time.timeZone = "Europe/Bratislava";

  # --- Networking ---

  networking = {
    modemmanager.enable = false;
    networkmanager.enable = true;
  };

  # --- Shell ---

  programs.zsh.enable = true;

  # --- Documentation ---

  documentation = {
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  # --- Users ---

  users.users.vs = {
    description = "Vlad Suchy";
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  security.sudo.wheelNeedsPassword = false;
}
