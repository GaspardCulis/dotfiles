{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.uptime-kuma;
  domain = config.gasdev.server.domain;
in {
  options.gasdev.services.uptime-kuma = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "uptime.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal container port";
      default = 3001;
    };
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.port}
    '';

    virtualisation.oci-containers.containers = {
      uptime-kuma = {
        image = "docker.io/louislam/uptime-kuma:1";
        pull = "newer";
        autoStart = true;
        ports = ["127.0.0.1:${toString cfg.port}:3001"];
        volumes = [
          "uptime-kuma:/app/data"
          # For container monitoring
          "/var/run/podman/podman.sock:/var/run/podman/podman.sock"
        ];
      };
    };
  };
}
