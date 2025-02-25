{
  config,
  domain,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.uptime-kuma;
in {
  options.gasdev.services.uptime-kuma = {
    enable = mkEnableOption "Enable Uptime Kuma service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Defines the domain on which Uptime Kuma is served.";
      default = "uptime.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Defines the port on which Uptime Kuma runs on.";
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
