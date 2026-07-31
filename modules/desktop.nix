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
      };
    };
  };

  # --- Fonts ---

  fonts.packages = with pkgs; [
    cascadia-code
    font-awesome
    inter
  ];

  # --- Programs ---

  programs = {
    niri = {
      enable = true;
      useNautilus = false;
    };

    gtklock.enable = true;

    waybar = {
      enable = true;
      systemd.target = "niri.service";
    };
  };

  # --- Packages ---

  environment.systemPackages = with pkgs; [
    mako
    swayidle

    firefox
    ghostty
  ];
}
