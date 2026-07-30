{ pkgs, ... }:

{
  nix = {
    channel.enable = false;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # --- Documentation ---

  documentation = {
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  # --- Boot ---

  boot = {
    kernelParams = [ "quiet" "udev.log_level=3" "rd.systemd.show_status=auto" ];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;

      timeout = 0;
    };

    plymouth.enable = true;
  };

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
