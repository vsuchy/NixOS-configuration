{
  pkgs,
  ...
}:

{
  # --- Dotfiles ---

  home.file = {
    ".gemrc".source = ../../dotfiles/.gemrc;
    ".npmrc".source = ../../dotfiles/.npmrc;
  };

  # --- Packages ---

  home.packages = with pkgs; [
    cmake
    gcc
    gnumake
    pkg-config

    nodejs
    ruby
  ];
}
