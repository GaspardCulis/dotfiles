{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.outline;
  auth = config.gasdev.services.auth;
  mail = config.gasdev.services.mail;
in {
  options.gasdev.services.outline = {
    enable = mkEnableOption "Enable Outline service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Defines the domain on which Outline is served.";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Defines the port on which Outline runs on.";
    };
    secrets = {
      oidcClientSecretFile = mkOption {
        type = types.nonEmptyStr;
      };
      smtpPassword = mkOption {
        type = types.nonEmptyStr;
      };
    };
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${cfg.port}
    '';

    services.outline = {
      enable = true;
      port = cfg.port;
      publicUrl = "https://${cfg.domain}";
      forceHttps = false;

      oidcAuthentication = {
        authUrl = "https://${auth.domain}/api/oidc/authorization";
        userinfoUrl = "https://${auth.domain}/api/oidc/userinfo";
        tokenUrl = "https://${auth.domain}/api/oidc/token";
        displayName = "Authelia";
        clientId = "outline";
        clientSecretFile = cfg.secrets.oidcClientSecretFile;
        scopes = ["openid" "offline_access" "profile" "email"];
      };

      smtp = {
        host = "${mail.stmpDomain}";
        port = 465;
        username = "postmaster";
        passwordFile = config.secrets.smtpPassword;
        fromEmail = "outline@${mail.domain}";
        replyEmail = "no-reply@${mail.domain}";
      };

      storage = {
        storageType = "local";
        localRootDir = "/var/lib/outline/data";
      };
    };

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "outline"
      ];
  };
}
