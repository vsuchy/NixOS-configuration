{ pkgs, config, host, ... }:

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
        user = host.username;
      };

      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd ${niriSession}";
        user = "greeter";
      };
    };
  };

  # --- Niri ---

  programs.niri = {
    enable = true;
    useNautilus = false;
  };
}
