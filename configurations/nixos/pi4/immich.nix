{config, ...}: let
  domain = config.gasdev.server.domain;
  port = 2283;
in {
  services.caddy.virtualHosts."http://photos.${domain}".extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString port}
  '';

  services.immich = {
    enable = true;
    host = "127.0.0.1";
    port = port;

    mediaLocation = "/mnt/immich";
  };

  # Video acceleration
  services.immich.accelerationDevices = null;
  hardware.graphics.enable = true;
  users.users.immich.extraGroups = ["video" "render"];

  services.redis.servers.immich.logLevel = "warning";
}
