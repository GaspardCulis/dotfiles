{
  config,
  domain,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.umami;
in {
  options.gasdev.services.umami = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "analytics.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal port";
      default = 4341;
    };
  };

  config = {
    sops.secrets."umami/APP_SECRET".owner = "root";
    sops.secrets."umami/DB_USER".owner = "root";
    sops.secrets."umami/DB_PASS".owner = "root";

    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.port}
    '';

    sops.templates."umami.env" = {
      content = ''
        APP_SECRET=${config.sops.placeholder."umami/APP_SECRET"}
        DATABASE_URL=postgresql://${config.sops.placeholder."umami/DB_USER"}:${config.sops.placeholder."umami/DB_PASS"}@umami-db:5432/umami
      '';
      owner = "root";
    };
    sops.templates."umami-db.env" = {
      content = ''
        POSTGRES_USER=${config.sops.placeholder."umami/DB_USER"}
        POSTGRES_PASSWORD=${config.sops.placeholder."umami/DB_PASS"}
      '';
      owner = "root";
    };

    virtualisation.oci-containers.containers = {
      umami = {
        image = "ghcr.io/umami-software/umami:postgresql-latest";
        pull = "newer";
        autoStart = true;
        ports = ["127.0.0.1:${toString cfg.port}:3000"];
        dependsOn = ["umami-db"];
        environment = {
          DATABASE_TYPE = "postgresql";
        };
        environmentFiles = [
          config.sops.templates."umami.env".path
        ];
      };
      umami-db = {
        image = "docker.io/postgres:15-alpine";
        pull = "newer";
        autoStart = true;
        environment = {
          POSTGRES_DB = "umami";
        };
        environmentFiles = [
          config.sops.templates."umami-db.env".path
        ];
        volumes = [
          "umami-db-data:/var/lib/postgresql/data"
        ];
      };
    };
  };
}
