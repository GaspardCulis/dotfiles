{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.auth;
  domain = config.gasdev.server.domain;
  mail = config.gasdev.services.mail;
in {
  options.gasdev.services.auth = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "auth.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal container port";
      default = 9091;
    };
    clients = mkOption {
      type = lib.types.listOf lib.types.attrs;
      description = "OIDC Clients";
      default = [];
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."authelia/JWT_SECRET".owner = "root";
    sops.secrets."authelia/SMTP_PASSWORD".owner = "root";
    sops.secrets."authelia/SESSION_SECRET".owner = "root";
    sops.secrets."authelia/STORAGE_PASSWORD".owner = "root";
    sops.secrets."authelia/STORAGE_ENCRYPTION_KEY".owner = "root";
    sops.secrets."authelia/OIDC_HMAC_SECRET".owner = "root";
    sops.secrets."authelia/OIDC_JWKS_PRIVATE_KEY".owner = "root";

    services.caddy.virtualHosts."auth.gasdev.fr".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.port}
    '';

    virtualisation.oci-containers.containers = {
      authelia = {
        image = "docker.io/authelia/authelia:latest";
        pull = "newer";
        autoStart = true;
        ports = ["127.0.0.1:${toString cfg.port}:${toString cfg.port}"];
        environment = {
          AUTHELIA_IDENTITY_VALIDATION_RESET_PASSWORD_JWT_SECRET_FILE = "/secrets/JWT_SECRET";
          AUTHELIA_SESSION_SECRET_FILE = "/secrets/SESSION_SECRET";
          # AUTHELIA_STORAGE_POSTGRES_PASSWORD_FILE = "/secrets/STORAGE_PASSWORD";
          AUTHELIA_STORAGE_ENCRYPTION_KEY_FILE = "/secrets/STORAGE_ENCRYPTION_KEY";
          AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = "/secrets/SMTP_PASSWORD";
          AUTHELIA_IDENTITY_PROVIDERS_OIDC_HMAC_SECRET_FILE = "/secrets/OIDC_HMAC_SECRET";

          X_AUTHELIA_CONFIG_FILTERS = "template";
        };
        volumes = [
          "authelia-data:/data"
          "/run/secrets/authelia:/secrets"
          "/etc/authelia/configuration.yml:/config/configuration.yml"
          "/etc/authelia/jwks-config.yml:/config/jwks-config.yml"
        ];
        cmd = ["--config" "/config/configuration.yml,/config/jwks-config.yml"];
      };
    };

    environment.etc."authelia/configuration.yml".source = (pkgs.formats.yaml {}).generate "authelia-config.yml" {
      theme = "auto";

      access_control = {
        default_policy = "deny";
        rules = [
          {
            domain = "*.${domain}";
            policy = "one_factor";
          }
        ];
      };

      server = {
        address = "tcp://:9091/";
        endpoints = {authz = {forward-auth = {implementation = "ForwardAuth";};};};
      };

      session = {
        cookies = [
          {
            domain = "${domain}";
            authelia_url = "https://${cfg.domain}";
            default_redirection_url = "https://${cfg.domain}/authenticated";
          }
        ];
      };

      identity_providers = {
        oidc = {
          clients = cfg.clients;
        };
      };

      authentication_backend = {
        password_reset = {disable = false;};
        file = {
          path = "/data/users_database.yml";
          password = {algorithm = "argon2";};
        };
      };

      password_policy = {
        standard = {
          enabled = true;
          min_length = 10;
          max_length = 128;
          require_uppercase = true;
          require_lowercase = true;
          require_number = true;
          require_special = true;
        };
      };

      storage = {local = {path = "/data/db.sqlite3";};};

      notifier = {
        disable_startup_check = true;
        smtp = {
          address = "submissions://${mail.smtpDomain}:465";
          username = "postmaster";
          sender = "Authelia <authelia@${domain}>";
        };
      };

      log = {
        level = "info";
        format = "json";
      };

      totp = {
        issuer = "${domain}";
        algorithm = "SHA1";
        digits = 6;
        period = 30;
        skew = 1;
      };

      webauthn = {disable = true;};
      duo_api = {disable = true;};
      ntp = {address = "udp://time.cloudflare.com:123";};
    };

    environment.etc."authelia/jwks-config.yml".text = ''
      identity_providers:
        oidc:
          jwks:
            - key: {{ secret "/secrets/OIDC_JWKS_PRIVATE_KEY" | mindent 10 "|" | msquote }}
    '';
  };
}
