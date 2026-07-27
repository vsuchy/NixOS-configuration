{ config, pkgs, ... }:

let
  niriSession = "${config.programs.niri.package}/bin/niri-session";
in

{
  # --- Login manager ---

  services.greetd = {
    enable = true;
    useTextGreeter = true;

    settings = {
      initial_session = {
        command = niriSession;
        user = "vs";
      };

      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd ${niriSession}";
        user = "greeter";
      };
    };
  };

  # --- Fonts ---

  fonts.packages = with pkgs; [
    inter
    nerd-fonts.caskaydia-cove
  ];

  # --- Niri ---

  programs.niri = {
    enable = true;
    useNautilus = false;
  };

  # --- Waybar ---

  programs.waybar = {
    enable = true;
    systemd.target = "niri.service";
  };

  # --- Packages ---

  environment.systemPackages = with pkgs; [
    # --- Applications ---
    firefox
    ghostty

    # --- Theme ---
    adw-gtk3
    adwaita-icon-theme
    numix-icon-theme-circle
  ];
}
