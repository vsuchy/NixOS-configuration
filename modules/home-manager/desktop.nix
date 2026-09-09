{
  lib,
  nixpkgs-unstable,
  osConfig,
  pkgs,
  ...
}:

let
  gnomeBoxesEnabled = osConfig.virtualisation.libvirtd.enable;
  pkgsUnstable = nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in

{
  # --- Assets ---

  home.file = {
    "Pictures/Avatars/AvatarSilhouette.png".source = ../../assets/avatars/AvatarSilhouette.png;
    "Pictures/Wallpapers".source = ../../assets/wallpapers;
  };

  # --- Dotfiles ---

  xdg.configFile = {
    "ghostty/config".source = ../../dotfiles/.config/ghostty/config;
    "niri/config.kdl".source = ../../dotfiles/.config/niri/config.kdl;
    "niri/gnome-boxes.kdl" = lib.mkIf gnomeBoxesEnabled {
      source = ../../dotfiles/.config/niri/gnome-boxes.kdl;
    };
    "noctalia/config.toml".source = ../../dotfiles/.config/noctalia/config.toml;
  };

  # --- Packages ---

  home.packages =
    with pkgs;
    [
      pkgsUnstable.noctalia

      firefox
      ghostty
      obsidian
    ]
    ++ lib.optionals gnomeBoxesEnabled [ gnome-boxes ];

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
