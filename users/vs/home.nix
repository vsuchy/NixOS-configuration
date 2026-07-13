{ lib, ... }:

{
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  # --- Zsh ---

  programs.zsh = {
    enable = true;

    initContent = lib.mkOrder 1000 "PROMPT='%F{blue}%~%f %F{green}❯%f '";

    shellAliases = {
      ls = "LC_ALL=C ls -Ahl --color=always --group-directories-first --time-style=+'%Y-%m-%d %H:%M:%S'";
      sudo = "sudo -E";
    };

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    autosuggestion.strategy = [ "history" "completion" ];
  };

  # --- Dotfiles ---

  home.file = {
    # --- Console ---

    ".gitconfig".source = ../../dotfiles/.gitconfig;
    ".vimrc".source = ../../dotfiles/.vimrc;
    ".config/fastfetch/config.jsonc".source = ../../dotfiles/.config/fastfetch/config.jsonc;
    ".config/nvim/init.lua".source = ../../dotfiles/.config/nvim/init.lua;
    ".config/vifm/vifmrc".source = ../../dotfiles/.config/vifm/vifmrc;

    # --- Desktop ---

    ".config/ghostty/config".source = ../../dotfiles/.config/ghostty/config;
    ".config/niri/config.kdl".source = ../../dotfiles/.config/niri/config.kdl;
    ".config/waybar".source = ../../dotfiles/.config/waybar;

    # --- Development ---

    ".gemrc".source = ../../dotfiles/.gemrc;
    ".npmrc".source = ../../dotfiles/.npmrc;
  };

  # --- Theme ---

  gtk = {
    enable = true;

    theme = {
      name = "adw-gtk3-dark";
    };

    font = {
      name = "Inter";
      size = 10;
    };

    cursorTheme = {
      name = "Adwaita";
      size = 24;
    };

    iconTheme = {
      name = "Numix-Circle";
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "adw-gtk3-dark";
      color-scheme = "prefer-dark";
      font-name = "Inter 10";
      document-font-name = "Inter 10";
      cursor-theme = "Adwaita";
      cursor-size = 24;
      icon-theme = "Numix-Circle";
    };
  };

  xdg.configFile = {
    "gtk-3.0/gtk.css".source = builtins.fetchurl {
      sha256 = "0zz1j8bjnq3pc0ndyczp5kvhz119mwc8w4z7swgy3ngy5zwbzxp6";
      url = "https://raw.githubusercontent.com/lassekongo83/adw-colors/389dff2e6ae48438693473c97f0aac6a2fc019cf/themes/adw-dracula/gtk3-dark.css";
    };
    "gtk-4.0/gtk.css".source = builtins.fetchurl {
      sha256 = "1gb11m6v0wf6waxbhg9kfafal6h4l82f76x39xwzq7lg3fp9g491";
      url = "https://raw.githubusercontent.com/lassekongo83/adw-colors/389dff2e6ae48438693473c97f0aac6a2fc019cf/themes/adw-dracula/gtk4-dark.css";
    };
  };
}
