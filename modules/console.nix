{ pkgs, host, ... }:

{
  # --- Packages ---

  environment.systemPackages = with pkgs; [
    git
    vifm
    vim
  ];
}
