{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  gnomeBoxesEnabled = osConfig.virtualisation.libvirtd.enable;
  lockCommand = lib.getExe osConfig.programs.gtklock.package;
  wallpapers = ../../dotfiles/.config/wallpapers;
in

{
  # --- Dotfiles ---

  xdg.configFile = {
    "ghostty/config".source = ../../dotfiles/.config/ghostty/config;
    "gtklock/config.ini".source = ../../dotfiles/.config/gtklock/config.ini;
    "mako/config".source = ../../dotfiles/.config/mako/config;
    "niri/config.kdl".source = ../../dotfiles/.config/niri/config.kdl;
    "niri/gnome-boxes.kdl" = lib.mkIf gnomeBoxesEnabled {
      source = ../../dotfiles/.config/niri/gnome-boxes.kdl;
    };
    "wallpapers".source = wallpapers;
    "waybar".source = ../../dotfiles/.config/waybar;
  };

  # --- Packages ---

  home.packages =
    with pkgs;
    [
      swaybg

      firefox
      ghostty
      obsidian
    ]
    ++ lib.optionals osConfig.hardware.bluetooth.enable [ bluetui ]
    ++ lib.optionals gnomeBoxesEnabled [ gnome-boxes ];

  # --- Services ---

  services = {
    mako.enable = true;

    swayidle = {
      enable = true;
      systemdTargets = [ "niri.service" ];

      timeouts = [
        {
          timeout = 3600;
          command = lockCommand;
        }
      ];

      events = {
        "before-sleep" = lockCommand;
        lock = lockCommand;
      };
    };
  };

  # --- Waybar ---

  programs.waybar = {
    enable = true;

    systemd = {
      enable = true;
      targets = [ "niri.service" ];
    };
  };

  # --- Swaybg ---

  systemd.user.services.swaybg = {
    Install.WantedBy = [ "niri.service" ];

    Service = {
      ExecStart = "${lib.getExe pkgs.swaybg} ${
        lib.escapeShellArgs [
          "-m"
          "fill"
          "-i"
          "${wallpapers}/nixos_dracula.svg"
        ]
      }";

      Restart = "on-failure";
    };

    Unit = {
      ConditionEnvironment = "WAYLAND_DISPLAY";
      After = [ "niri.service" ];
      PartOf = [ "niri.service" ];
    };
  };

  # --- Theme ---

  xdg.configFile = {
    "gtk-3.0/gtk.css".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/lassekongo83/adw-colors/389dff2e6ae48438693473c97f0aac6a2fc019cf/themes/adw-dracula/gtk3-dark.css";
      hash = "sha256-5va/+C/+2eEf1+cTjhivKYQP9yz3M98sYHdgKxeS4X8=";
    };
    "gtk-4.0/gtk.css".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/lassekongo83/adw-colors/389dff2e6ae48438693473c97f0aac6a2fc019cf/themes/adw-dracula/gtk4-dark.css";
      hash = "sha256-IZGXrhuPHvx5T6Ob4wSiBBqqnHIzPbi64sZxsE0NYb0=";
    };
  };

  gtk = {
    enable = true;
    colorScheme = "dark";

    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    font = {
      name = "Inter";
      size = 10;
    };

    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };

    iconTheme = {
      name = "Numix-Circle";
      package = pkgs.numix-icon-theme-circle;
    };
  };

  dconf.settings."org/gnome/desktop/interface".document-font-name = "Inter 10";
}
