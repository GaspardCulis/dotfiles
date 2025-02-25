{
  config,
  domain,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.vaultwarden;
  mail = config.gasdev.services.mail;
in {
  options.gasdev.services.vaultwarden = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "vault.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal docker port used";
      default = 9092;
    };
  };

  config = {
    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.port}
    '';

    sops.secrets."vaultwarden/ADMIN_TOKEN".owner = "root";
    sops.secrets."vaultwarden/SMTP_USERNAME".owner = "root";
    sops.secrets."vaultwarden/SMTP_PASSWORD".owner = "root";
    sops.templates."vaultwarden.env" = {
      content = ''
        ADMIN_TOKEN=${config.sops.placeholder."vaultwarden/ADMIN_TOKEN"}
        SMTP_USERNAME=${config.sops.placeholder."vaultwarden/SMTP_USERNAME"}
        SMTP_PASSWORD=${config.sops.placeholder."vaultwarden/SMTP_PASSWORD"}
      '';
      owner = "root";
    };

    virtualisation.oci-containers.containers = {
      vaultwarden = {
        image = "docker.io/vaultwarden/server:latest-alpine";
        pull = "newer";
        autoStart = true;
        ports = [
          "127.0.0.1:${toString cfg.port}:80"
        ];
        volumes = [
          "vaultwarden-data:/data/"
        ];
        environment = {
          SIGNUPS_ALLOWED = "false";
          DOMAIN = "http://${cfg.domain}";
          # SMTP
          SMTP_HOST = "${mail.smtpDomain}";
          SMTP_PORT = "465";
          SMTP_FROM = "vaultwarden@${domain}";
          SMTP_SECURITY = "force_tls";
        };
        environmentFiles = [
          config.sops.templates."vaultwarden.env".path
        ];
      };
    };
  };
}
