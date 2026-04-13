{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.vikunja;
  domain = config.gasdev.server.domain;
  mail = config.gasdev.services.mail;
in {
  options.gasdev.services.vikunja = {
    enable = mkEnableOption "Enable service";
    registration.enable = mkEnableOption "Whether to let new users registering themselves or not";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "todo.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal port";
      default = 7124;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."vikunja/SERVICE_JWTSECRET".owner = "root";
    sops.secrets."vikunja/MAILER_USERNAME".owner = "root";
    sops.secrets."vikunja/MAILER_PASSWORD".owner = "root";

    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.port}
    '';

    sops.templates."vikunja.env" = {
      content = ''
        VIKUNJA_SERVICE_JWTSECRET=${config.sops.placeholder."vikunja/SERVICE_JWTSECRET"}
        VIKUNJA_MAILER_USERNAME=${config.sops.placeholder."vikunja/MAILER_USERNAME"}
        VIKUNJA_MAILER_PASSWORD=${config.sops.placeholder."vikunja/MAILER_PASSWORD"}
      '';
      owner = "root";
    };

    virtualisation.oci-containers.containers = {
      vikunja = {
        image = "docker.io/vikunja/vikunja:2";
        pull = "newer";
        autoStart = true;
        ports = [
          "127.0.0.1:${toString cfg.port}:3456"
        ];
        volumes = [
          "vikunja-files:/app/vikunja/files"
          "vikunja-db:/db"
        ];
        environment = {
          VIKUNJA_SERVICE_PUBLICURL = "https://${cfg.domain}";
          VIKUNJA_DATABASE_PATH = "/db/vikunja.db";

          # SMTP
          VIKUNJA_MAILER_ENABLED = "true";
          VIKUNJA_MAILER_HOST = "${mail.smtpDomain}";
          VIKUNJA_MAILER_PORT = "587";
          VIKUNJA_MAILER_USERNAME = "todo@${domain}";

          VIKUNJA_SERVICE_ENABLEREGISTRATION =
            if cfg.registration.enable
            then "true"
            else "false";
        };
        environmentFiles = [
          config.sops.templates."vikunja.env".path
        ];
      };
    };
  };
}
