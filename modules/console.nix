{ pkgs, ... }:

{
  # --- Packages ---

  environment.systemPackages = with pkgs; [
    ast-grep
    ripgrep
    tree-sitter
    unzip
    wget
    zip

    fastfetch
    git
    neovim
    vifm
    vim
  ];
}
