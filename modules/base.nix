{
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

    loader = {
      efi.canTouchEfiVariables = true;
      timeout = 0;

      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
    };

    plymouth.enable = true;
  };

  # --- Time ---

  time.timeZone = "Europe/Bratislava";

  # --- Networking ---

  networking.networkmanager.enable = true;

  # --- Shell ---

  programs.zsh.enable = true;

  # --- Users ---

  users.users.${username} = {
    description = "Vlad Suchy";
    isNormalUser = true;
    shell = pkgs.zsh;

    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  security.sudo.wheelNeedsPassword = false;
}
