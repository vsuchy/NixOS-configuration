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

  networking.networkmanager.enable = true;

  # --- Shell ---

  programs.zsh.enable = true;

  # --- Users ---

  users.users.vs = {
    description = "Vlad Suchy";
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  security.sudo.wheelNeedsPassword = false;
}
