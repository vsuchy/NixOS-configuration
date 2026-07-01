{ pkgs, host, ... }:

{
  # --- Packages ---

  environment.systemPackages = with pkgs; [
    fastfetch
    git
    vifm
    vim
  ];
}
