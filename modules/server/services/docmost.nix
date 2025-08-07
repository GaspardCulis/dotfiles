{
  config,
  domain,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.docmost;
in {
  options.gasdev.services.docmost = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "docs.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal port";
      default = 9063;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."domost/APP_SECRET".owner = "root";
    sops.secrets."docmost/DB_USER".owner = "root";
    sops.secrets."docmost/DP_PASS".owner = "root";

    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.port}
    '';

    sops.templates."docmost.env" = {
      content = ''
        APP_SECRET=${config.sops.placeholder."docmost/APP_SECRET"}
        DATABASE_URL=postgresql://${config.sops.placeholder."docmost/DB_USER"}:${config.sops.placeholder."docmost/DB_PASS"}@docmost-db:5432/docmost?schema=public
      '';
      owner = "root";
    };
    sops.templates."docmost-db.env" = {
      content = ''
        POSTGRES_USER=${config.sops.placeholder."docmost/DB_USER"}
        POSTGRES_PASSWORD=${config.sops.placeholder."docmost/DB_PASS"}
      '';
      owner = "root";
    };

    virtualisation.oci-containers.containers = {
      docmost = {
        image = "docker.io/docmost/docmost:latest";
        pull = "newer";
        autoStart = true;
        ports = ["127.0.0.1:${toString cfg.port}:3000"];
        dependsOn = ["docmost-db"];
        environment = {
          APP_URL = "https//${cfg.domain}";
          REDIS_URL = "redis://docmost-redis:6379";
          DISABLE_TELEMETRY = "true";
        };
        environmentFiles = [
          config.sops.templates."docmost.env".path
        ];
        volumes = [
          "docmost:/app/data/storage"
        ];
      };
      docmost-db = {
        image = "docker.io/postgres:16-alpine";
        pull = "newer";
        autoStart = true;
        environment = {
          POSTGRES_DB = "docmost";
        };
        environmentFiles = [
          config.sops.templates."docmost-db.env".path
        ];
        volumes = [
          "docmost_db_data:/var/lib/postgresql/data"
        ];
      };
      docmost-redis = {
        image = "docker.io/redis:7.2-alpine";
        pull = "newer";
        autoStart = true;
        volumes = [
          "docmost_redis_data:/data"
        ];
      };
    };
  };
}
