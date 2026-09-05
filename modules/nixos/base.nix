{
  fullName,
  pkgs,
  username,
  ...
}:

{
  nix = {
    channel.enable = false;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # --- Documentation ---

  documentation = {
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  # --- Boot ---

  boot = {
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];

    loader.timeout = 0;
    plymouth.enable = true;
  };

  # --- Time ---

  time.timeZone = "Europe/Bratislava";

  # --- Networking ---

  networking.networkmanager.enable = true;

  # --- Services ---

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
    };

    printing = {
      enable = true;

      drivers = with pkgs; [
        brlaser
      ];
    };

    power-profiles-daemon.enable = true;
    upower.enable = true;
  };

  # --- Shell ---

  programs.zsh.enable = true;

  # --- Users ---

  users.users.${username} = {
    description = fullName;
    isNormalUser = true;
    shell = pkgs.zsh;

    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  security.sudo.wheelNeedsPassword = false;
}
