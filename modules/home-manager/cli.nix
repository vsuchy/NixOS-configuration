{
  config,
  nixpkgs-unstable,
  pkgs,
  ...
}:

let
  pkgsUnstable = nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in

{
  # --- Dotfiles ---

  home.file = {
    ".gitconfig".source = ../../dotfiles/.gitconfig;
    ".vimrc".source = ../../dotfiles/.vimrc;
  };

  xdg.configFile = {
    "fastfetch/config.jsonc".source = ../../dotfiles/.config/fastfetch/config.jsonc;
    "vifm/vifmrc".source = ../../dotfiles/.config/vifm/vifmrc;
  };

  # --- Packages ---

  home.packages = with pkgs; [
    ast-grep
    brightnessctl
    ddcutil
    imagemagick
    jq
    libnotify
    ripgrep
    unzip
    wget
    wl-clipboard
    zip

    fastfetch
    git
    vifm
    vim

    pkgsUnstable.codex
  ];

  # --- Programs ---

  programs = {
    zsh = {
      enable = true;

      initContent = "PROMPT='%F{blue}%~%f %F{green}❯%f '";
      history.path = "${config.xdg.dataHome}/zsh/.zsh_history";

      shellAliases = {
        ls = "LC_ALL=C ls -Ahl --color=always --group-directories-first --time-style=+'%Y-%m-%d %H:%M:%S'";
        sudoe = "sudo -E";
      };

      completionInit = ''
        mkdir -p "${config.xdg.dataHome}/zsh"
        autoload -U compinit
        compinit -d "${config.xdg.dataHome}/zsh/.zcompdump"
      '';

      autosuggestion = {
        enable = true;
        strategy = [
          "history"
          "completion"
        ];
      };

      syntaxHighlighting.enable = true;
    };

    neovim = {
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
  };
}
