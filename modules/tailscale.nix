{ username, ... }:

{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";

    extraSetFlags = [
      "--operator=${username}"
      "--exit-node-allow-lan-access"
      "--exit-node=sk-bts-wg-001.mullvad.ts.net"
    ];
  };

  systemd.services.tailscaled-set.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "5s";
  };
}
