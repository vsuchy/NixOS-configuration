{ pkgs, host, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # --- Boot ---

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  boot.initrd.systemd.enable = true;
  boot.kernelParams = [ "quiet" "udev.log_level=3" "rd.systemd.show_status=auto" ];

  boot.plymouth.enable = true;

  # --- Time ---

  time.timeZone = "Europe/Bratislava";
  services.timesyncd.enable = true;

  # --- Localization ---

  console.keyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";

  # --- Networking ---

  networking.hostName = host.hostname;
  networking.modemmanager.enable = false;
  networking.networkmanager.enable = true;

  # --- Shell ---

  programs.zsh.enable = true;

  # --- Users ---

  users.users = {
    ${host.username} = {
      description = host.userFullName;
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [ "networkmanager" "wheel" ];
    };
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;
}
