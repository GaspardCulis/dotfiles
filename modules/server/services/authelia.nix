{
  config,
  domain,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.auth;
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
        ];
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
          jwks = [{key = "{{ secret \"/secrets/OIDC_JWKS_PRIVATE_KEY\" | mindent 10 \"|\" | msquote }}";}];
          clients = [
            {
              client_id = "penpot";
              client_name = "Penpot";
              client_secret = "$pbkdf2-sha512$310000$WuYHbHrVI3wMn/tZXwDTMA$WnS0VoR4jLNQnXjJUN46EfnC4QMdpdnNcYsGvSCpkbzguO4of.tCgAeLsfzLgWn9CSGMt20TZOQfc/7IbfwBHg";
              redirect_uris = "https://penpot.gasdev.fr/api/auth/oauth/oidc/callback";
              token_endpoint_auth_method = "client_secret_post";
              authorization_policy = "one_factor";
              scopes = ["email" "openid" "profile"];
            }
            {
              client_id = "outline";
              client_name = "Outline";
              client_secret = "$pbkdf2-sha512$310000$KykggigTF2ZRKzEdHqPD0A$TV66lPDqlTodPjFGMpxMUaeQPywHliW8yTXfXsMh4EBkYI3cIqmDc.z6Yk/3/So2.HqsRWwfPlEHmBn9Esq/4A";
              public = false;
              authorization_policy = "one_factor";
              redirect_uris = ["https://outline.gasdev.fr/auth/oidc.callback"];
              scopes = ["openid" "offline_access" "profile" "email"];
              userinfo_signed_response_alg = "none";
              token_endpoint_auth_method = "client_secret_post";
            }
          ];
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
  };
}
