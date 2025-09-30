{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.tandoor;
  domain = config.gasdev.server.domain;
  mail = config.gasdev.services.mail;
in {
  options.gasdev.services.tandoor = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "cook.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal port";
      default = 7439;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."tandoor/SECRET_KEY".owner = "root";
    sops.secrets."tandoor/S3_ACCESS_KEY".owner = "root";
    sops.secrets."tandoor/S3_SECRET_ACCESS_KEY".owner = "root";
    sops.secrets."tandoor/POSTGRES_USER".owner = "root";
    sops.secrets."tandoor/POSTGRES_PASSWORD".owner = "root";
    sops.secrets."tandoor/SMTP_USERNAME".owner = "root";
    sops.secrets."tandoor/SMTP_PASSWORD".owner = "root";

    sops.templates."tandoor.env" = {
      content = ''
        SECRET_KEY=${config.sops.placeholder."tandoor/SECRET_KEY"}

        S3_REGION_NAME=garage
        S3_BUCKET_NAME=tandoor
        S3_ENDPOINT_URL=https://s3.gasdev.fr
        S3_CUSTOM_DOMAIN=tandoor.s3web.gasdev.fr
        S3_ACCESS_KEY=${config.sops.placeholder."tandoor/S3_ACCESS_KEY"}
        S3_SECRET_ACCESS_KEY=${config.sops.placeholder."tandoor/S3_SECRET_ACCESS_KEY"}

        EMAIL_HOST=${mail.smtpDomain}
        EMAIL_PORT=465
        EMAIL_USE_SSL=1
        EMAIL_HOST_USER=${config.sops.placeholder."tandoor/SMTP_USERNAME"}
        EMAIL_HOST_PASSWORD=${config.sops.placeholder."tandoor/SMTP_PASSWORD"}
        DEFAULT_FROM_EMAIL=tandoor@gasdev.fr
      '';
      owner = "root";
    };

    sops.templates."tandoor-db.env" = {
      content = ''
        POSTGRES_DB=djangodb
        POSTGRES_PORT=5432
        POSTGRES_USER=${config.sops.placeholder."tandoor/POSTGRES_USER"}
        POSTGRES_PASSWORD=${config.sops.placeholder."tandoor/POSTGRES_PASSWORD"}
      '';
      owner = "root";
    };

    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.port}
    '';

    virtualisation.oci-containers.containers = {
      tandoor = {
        image = "docker.io/vabene1111/recipes";
        pull = "newer";
        autoStart = true;
        dependsOn = ["tandoor-db"];
        environment = {
          DB_ENGINE = "django.db.backends.postgresql";
          POSTGRES_HOST = "tandoor-db";
        };
        environmentFiles = [
          config.sops.templates."tandoor.env".path
          config.sops.templates."tandoor-db.env".path
        ];
        ports = [
          "127.0.0.1:${toString cfg.port}:8080"
        ];
        volumes = [
          "tandoor-staticfiles:/opt/recipes/staticfiles"
        ];
      };

      tandoor-db = {
        image = "docker.io/postgres:16-alpine";
        pull = "newer";
        autoStart = true;
        environmentFiles = [
          config.sops.templates."tandoor-db.env".path
        ];
        volumes = [
          "tandoor-db:/var/lib/postgresql/data"
        ];
      };
    };
  };
}
