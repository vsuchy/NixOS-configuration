{
  config,
  lib,
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
        command = "${lib.getExe pkgs.tuigreet} -u ${username} -c ${config.programs.niri.package}/bin/niri-session";
      };
    };
  };

  # --- Audio ---

  services = {
    pipewire = {
      enable = true;

      alsa = {
        enable = true;
        support32Bit = false;
      };

      pulse.enable = true;
      wireplumber.enable = true;
    };

    pulseaudio.enable = false;
  };

  security.rtkit.enable = true;

  # --- Fonts ---

  fonts.packages = with pkgs; [
    cascadia-code
    inter
  ];

  # --- Niri ---

  programs.niri = {
    enable = true;
    useNautilus = false;
  };
}
