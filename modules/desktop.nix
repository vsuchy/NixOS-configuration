{
  config,
  pkgs,
  username,
  ...
}:

{
  # --- Login manager ---

  services.greetd = {
    enable = true;
    useTextGreeter = true;

    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet -u ${username} -c ${config.programs.niri.package}/bin/niri-session";
      };
    };
  };

  # --- Audio ---

  security.rtkit.enable = true;

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
  };
}
