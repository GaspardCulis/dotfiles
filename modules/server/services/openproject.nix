{
  config,
  domain,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.openproject;
in {
  options.gasdev.services.openproject = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "project.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal container port";
      default = 9407;
    };
  };
  config = mkIf cfg.enable {
    sops.secrets."openproject/SECRET_KEY_BASE".owner = "root";

    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.port}
    '';

    sops.templates."openproject.env" = {
      content = ''
        OPENPROJECT_SECRET_KEY_BASE=${config.sops.placeholder."openproject/SECRET_KEY_BASE"}
      '';
      owner = "root";
    };

    virtualisation.oci-containers.containers = {
      openproject = {
        image = "docker.io/openproject/openproject:15";
        pull = "newer";
        autoStart = true;
        ports = [
          "127.0.0.1:${toString cfg.port}:80"
        ];
        volumes = [
          "openproject-data:/var/openproject/pgdata"
          "openproject-assets:/var/openproject/assets"
        ];
        environment = {
          OPENPROJECT_HOST__NAME = "${cfg.domain}";
          OPENPROJECT_HTTPS = "true";
        };
        environmentFiles = [
          config.sops.templates."openproject.env".path
        ];
      };
    };
  };
}
