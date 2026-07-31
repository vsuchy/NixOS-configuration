{ pkgs, ... }:

{
  home.stateVersion = "26.05";

  manual.manpages.enable = false;

  # --- Dotfiles ---

  home.file = {
    ".gemrc".source = ../../dotfiles/.gemrc;
    ".gitconfig".source = ../../dotfiles/.gitconfig;
    ".npmrc".source = ../../dotfiles/.npmrc;
    ".vimrc".source = ../../dotfiles/.vimrc;
  };

  xdg.configFile = {
    # --- Console ---

    "fastfetch/config.jsonc".source = ../../dotfiles/.config/fastfetch/config.jsonc;
    "vifm/vifmrc".source = ../../dotfiles/.config/vifm/vifmrc;

    # --- Desktop ---

    "ghostty/config".source = ../../dotfiles/.config/ghostty/config;
    "mako/config".source = ../../dotfiles/.config/mako/config;
    "niri/config.kdl".source = ../../dotfiles/.config/niri/config.kdl;
    "swayidle/config".source = ../../dotfiles/.config/swayidle/config;
    "waybar".source = ../../dotfiles/.config/waybar;

    # --- Theme ---

    "gtk-3.0/gtk.css".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/lassekongo83/adw-colors/389dff2e6ae48438693473c97f0aac6a2fc019cf/themes/adw-dracula/gtk3-dark.css";
      hash = "sha256-5va/+C/+2eEf1+cTjhivKYQP9yz3M98sYHdgKxeS4X8=";
    };
    "gtk-4.0/gtk.css".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/lassekongo83/adw-colors/389dff2e6ae48438693473c97f0aac6a2fc019cf/themes/adw-dracula/gtk4-dark.css";
      hash = "sha256-IZGXrhuPHvx5T6Ob4wSiBBqqnHIzPbi64sZxsE0NYb0=";
    };
  };

  # --- Zsh ---

  programs.zsh = {
    enable = true;

    initContent = "PROMPT='%F{blue}%~%f %F{green}❯%f '";

    shellAliases = {
      ls = "LC_ALL=C ls -Ahl --color=always --group-directories-first --time-style=+'%Y-%m-%d %H:%M:%S'";
      sudo = "sudo -E";
    };

    autosuggestion = {
      enable = true;
      strategy = [
        "history"
        "completion"
      ];
    };

    syntaxHighlighting.enable = true;
  };

  # --- Neovim ---

  programs.neovim = {
    enable = true;
    initLua = builtins.readFile ../../dotfiles/.config/nvim/init.lua;

    extraPackages = with pkgs; [
      bash-language-server
      lua-language-server
      rubocop
      shellcheck
      vscode-langservers-extracted
    ];

    plugins = with pkgs.vimPlugins; [
      blink-cmp
      dracula-nvim
      friendly-snippets
      gitsigns-nvim
      grug-far-nvim
      lualine-nvim
      mini-nvim
      nvim-treesitter.withAllGrammars
      render-markdown-nvim
    ];
  };

  # --- Theme ---

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
