{
  config,
  domain,
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
      default = "outline.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Defines the port on which Outline runs on.";
      default = 7143;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."outline/OIDC_CLIENT_SECRET".owner = "outline";
    sops.secrets."outline/SMTP_PASSWORD".owner = "outline";
    sops.secrets."outline/S3_SECRET_KEY".owner = "outline";

    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.port}
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
        clientSecretFile = config.sops.secrets."outline/OIDC_CLIENT_SECRET".path;
        scopes = ["openid" "offline_access" "profile" "email"];
      };

      smtp = {
        host = "${mail.smtpDomain}";
        port = 465;
        username = "postmaster";
        passwordFile = config.sops.secrets."outline/SMTP_PASSWORD".path;
        fromEmail = "outline@${domain}";
        replyEmail = "no-reply@${domain}";
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
