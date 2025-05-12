{
  config,
  domain,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.openproject;
  mail = config.gasdev.services.mail;
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
    sops.secrets."openproject/SMTP_USER_NAME".owner = "root";
    sops.secrets."openproject/SMTP_PASSWORD".owner = "root";

    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.port}
    '';

    sops.templates."openproject.env" = {
      content = ''
        OPENPROJECT_SECRET_KEY_BASE=${config.sops.placeholder."openproject/SECRET_KEY_BASE"}
        OPENPROJECT_SMTP__USER__NAME=${config.sops.placeholder."openproject/SMTP_USER_NAME"}
        OPENPROJECT_SMTP__PASSWORD=${config.sops.placeholder."openproject/SMTP_PASSWORD"}
      '';
      owner = "root";
    };

    virtualisation.oci-containers.containers = {
      openproject = {
        image = "docker.io/openproject/openproject:15-slim";
        # pull = "newer";
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
          # SMTP
          OPENPROJECT_MAIL__FROM = "openproject@${domain}";
          OPENPROJECT_EMAIL__DELIVERY__METHOD = "smtp";
          OPENPROJECT_SMTP__ADDRESS = "${mail.smtpDomain}";
          OPENPROJECT_SMTP__PORT = "465";
          OPENPROJECT_SMTP__DOMAIN = "${domain}";
          OPENPROJECT_SMTP__AUTHENTICATION = "plain";
          OPENPROJECT_SMTP__SSL = "true";
          # Perf
          OPENPROJECT_WEB_WORKERS = "1";
          OPENPROJECT_WEB_MIN__THREADS = "1";
        };
        environmentFiles = [
          config.sops.templates."openproject.env".path
        ];
      };
    };
  };
}
