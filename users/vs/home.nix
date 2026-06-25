{ lib, host, ... }:

{
  home.stateVersion = "26.05";

  home.username = host.username;
  home.homeDirectory = "/home/${host.username}";

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;

    initContent = lib.mkOrder 1000 "PROMPT='%F{blue}%~%f %F{green}❯%f '";

    shellAliases = {
      ls = "LC_ALL=C ls -Ahl --color=always --group-directories-first --time-style=+'%Y-%m-%d %H:%M:%S'";
    };

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    autosuggestion.strategy = [ "history" "completion" ];
  };

  home.file = {
    ".vimrc".source = ../../dotfiles/.vimrc;
    ".config/vifm/vifmrc".source = ../../dotfiles/.config/vifm/vifmrc;
  };
}
