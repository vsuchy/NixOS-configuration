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

  # --- Fonts ---

  fonts.packages = with pkgs; [
    inter
    nerd-fonts.caskaydia-cove
  ];

  fonts.fontconfig.localConf = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      <alias binding="same">
        <family>Cascadia Code NF</family>
        <prefer>
          <family>CaskaydiaCove NF</family>
        </prefer>
      </alias>
    </fontconfig>
    '';

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

  # --- Applications ---

  environment.systemPackages = with pkgs; [
    firefox
    ghostty
  ];
}
