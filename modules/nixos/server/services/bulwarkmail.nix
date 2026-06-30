{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.bulwarkmail;
  domain = config.gasdev.server.domain;
  mail = config.gasdev.services.mail;
in {
  options.gasdev.services.bulwarkmail = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "webmail.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal port";
      default = 30783;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."bulwarkmail/ADMIN_PASSWORD".owner = config.gasdev.server.containersUser;
    sops.secrets."bulwarkmail/SESSION_SECRET".owner = config.gasdev.server.containersUser;

    sops.templates."bulwarkmail.env" = {
      content = ''
        ADMIN_PASSWORD=${config.sops.placeholder."bulwarkmail/ADMIN_PASSWORD"}
        SESSION_SECRET=${config.sops.placeholder."bulwarkmail/SESSION_SECRET"}
      '';
      owner = config.gasdev.server.containersUser;
    };

    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.port}
    '';

    gasdev.server.containers = {
      bulwarkmail = {
        image = "ghcr.io/bulwarkmail/webmail:latest";
        pull = "newer";
        autoStart = true;
        volumes = [
          "bulwark-config:/app/data/admin"
          "bulwark-state:/app/data/admin-state"
        ];
        ports = [
          "127.0.0.1:${toString cfg.port}:3000"
        ];
        environment = {
          JMAP_SERVER_URL = "https://${mail.jmapDomain}";

          APP_NAME = "Gasmail";
          LOGIN_COMPANY_NAME = "Gasdev";

          SETTINGS_SYNC_ENABLED = "true";
          BULWARK_TELEMETRY = "false";
        };
        environmentFiles = [
          config.sops.templates."bulwarkmail.env".path
        ];
      };
    };
  };
}
