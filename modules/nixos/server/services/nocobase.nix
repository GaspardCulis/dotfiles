{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.nocobase;
  domain = config.gasdev.server.domain;
in {
  options.gasdev.services.nocobase = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "nocobase.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal port";
      default = 2060;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."nocobase/APP_KEY".owner = config.gasdev.server.containersUser;
    sops.secrets."nocobase/DB_USER".owner = config.gasdev.server.containersUser;
    sops.secrets."nocobase/DB_PASSWORD".owner = config.gasdev.server.containersUser;

    sops.templates."nocobase.env" = {
      content = ''
        APP_KEY=${config.sops.placeholder."nocobase/APP_KEY"}
        DB_USER=${config.sops.placeholder."nocobase/DB_USER"}
        DB_PASSWORD=${config.sops.placeholder."nocobase/DB_PASSWORD"}
      '';
      owner = config.gasdev.server.containersUser;
    };
    sops.templates."nocobase-db.env" = {
      content = ''
        POSTGRES_USER=${config.sops.placeholder."nocobase/DB_USER"}
        POSTGRES_PASSWORD=${config.sops.placeholder."nocobase/DB_PASSWORD"}
      '';
      owner = config.gasdev.server.containersUser;
    };

    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.port}
    '';

    gasdev.server.containers = {
      nocobase = {
        image = "docker.io/nocobase/nocobase:latest-full";
        pull = "newer";
        autoStart = true;
        volumes = [
          "nocobase-storage:/app/nocobase/storage"
        ];
        ports = [
          "127.0.0.1:${toString cfg.port}:80"
        ];
        dependsOn = ["nocobase-db"];
        environment = {
          APP_ENV = "production";
          DB_DIALECT = "postgres";
          DB_HOST = "nocobase-db";
          DB_PORT = "5432";
          DB_DATABASE = "nocobase";
          TZ = "Europe/Paris";
        };
        environmentFiles = [
          config.sops.templates."nocobase.env".path
        ];
      };
      nocobase-db = {
        image = "docker.io/postgres:16-alpine";
        pull = "newer";
        autoStart = true;
        environment = {
          POSTGRES_DB = "nocobase";
        };
        environmentFiles = [
          config.sops.templates."nocobase-db.env".path
        ];
        volumes = [
          "nocobase-db-data:/var/lib/postgresql/data"
        ];
      };
    };
  };
}
