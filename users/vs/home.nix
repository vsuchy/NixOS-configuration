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
    "niri/config.kdl".source = ../../dotfiles/.config/niri/config.kdl;
    "waybar".source = ../../dotfiles/.config/waybar;

    # --- Theme ---

    "gtk-3.0/gtk.css".source = builtins.fetchurl {
      sha256 = "0zz1j8bjnq3pc0ndyczp5kvhz119mwc8w4z7swgy3ngy5zwbzxp6";
      url = "https://raw.githubusercontent.com/lassekongo83/adw-colors/389dff2e6ae48438693473c97f0aac6a2fc019cf/themes/adw-dracula/gtk3-dark.css";
    };
    "gtk-4.0/gtk.css".source = builtins.fetchurl {
      sha256 = "1gb11m6v0wf6waxbhg9kfafal6h4l82f76x39xwzq7lg3fp9g491";
      url = "https://raw.githubusercontent.com/lassekongo83/adw-colors/389dff2e6ae48438693473c97f0aac6a2fc019cf/themes/adw-dracula/gtk4-dark.css";
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

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    autosuggestion.strategy = [ "history" "completion" ];
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

  dconf.settings."org/gnome/desktop/interface".document-font-name = "Inter 10";
}
