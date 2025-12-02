{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.mail;
  domain = config.gasdev.server.domain;
in {
  options.gasdev.services.mail = {
    enable = mkEnableOption "Enable service";
    smtpDomain = mkOption {
      type = types.nonEmptyStr;
      description = "Public SMTP domain";
      default = "mail.${domain}";
    };
    adminDomain = mkOption {
      type = types.nonEmptyStr;
      description = "Public Web admin-panel domain";
      default = "mailadmin.${domain}";
    };
    jmapPort = mkOption {
      type = types.ints.unsigned;
      description = "Internal JMAP port";
      default = 8080;
    };
    adminPort = mkOption {
      type = types.ints.unsigned;
      description = "Internal Web admin-panel port";
      default = 40312;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."stalwart-mail/ADMIN_SECRET".owner = "stalwart-mail";
    sops.secrets."stalwart-mail/ACME_SECRET".owner = "stalwart-mail";

    sops.secrets."stalwart-mail/SIGNATURE_KEY_RSA".owner = "stalwart-mail";
    sops.secrets."stalwart-mail/SIGNATURE_KEY_ED25519".owner = "stalwart-mail";

    sops.secrets."stalwart-mail/S3_BUCKET".owner = "stalwart-mail";
    sops.secrets."stalwart-mail/S3_REGION".owner = "stalwart-mail";
    sops.secrets."stalwart-mail/S3_ENDPOINT".owner = "stalwart-mail";
    sops.secrets."stalwart-mail/S3_ACCESS_KEY".owner = "stalwart-mail";
    sops.secrets."stalwart-mail/S3_SECRET_KEY".owner = "stalwart-mail";

    services.caddy.virtualHosts."${cfg.adminDomain}" = {
      extraConfig = ''
        reverse_proxy http://127.0.01:${toString cfg.adminPort}
      '';
    };
    services.caddy.virtualHosts."${cfg.smtpDomain}" = {
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.jmapPort}
      '';
      serverAliases = [
        "mta-sts.${domain}"
        "autoconfig.${domain}"
        "autodiscover.${domain}"
        "${domain}"
      ];
    };
    networking.firewall.allowedTCPPorts = [25 465 587 993];

    services.stalwart-mail = {
      enable = true;
      settings = {
        server = {
          hostname = "${cfg.smtpDomain}";
          tls = {
            enable = true;
            implicit = true;
          };
          listener = {
            smtp = {
              protocol = "smtp";
              bind = "[::]:25";
            };
            submissions = {
              bind = "[::]:465";
              protocol = "smtp";
              tls.implicit = true;
            };
            imaps = {
              bind = "[::]:993";
              protocol = "imap";
              tls.implicit = true;
            };
            jmap = {
              bind = "[::]:${toString cfg.jmapPort}";
              protocol = "http";
              tls.implicit = false;
            };
            management = {
              bind = ["127.0.0.1:${toString cfg.adminPort}"];
              protocol = "http";
            };
          };
        };
        lookup.default = {
          hostname = "${cfg.smtpDomain}";
          domain = "${domain}";
        };
        certificate.default = {
          default = true;
          cert = "%{file:/var/lib/stalwart-mail/cert/${cfg.smtpDomain}.pem}%";
          private-key = "%{file:/var/lib/stalwart-mail/cert/${cfg.smtpDomain}.priv.pem}%";
        };
        session.auth = {
          mechanisms = "[plain, login]";
        };
        directory."imap".lookup.domains = ["${domain}"];
        auth.dkim = {
          sign = [
            {
              "if" = "listener != 'smtp'";
              "then" = "['rsa', 'ed25519']";
            }
            {"else" = false;}
          ];
        };
        signatures = {
          rsa = {
            private-key = "%{file:${config.sops.secrets."stalwart-mail/SIGNATURE_KEY_RSA".path}}%";
            domain = "${domain}";
            selector = "rsa-default";
            headers = ["From" "To" "Cc" "Date" "Subject" "Message-ID" "Organization" "MIME-Version" "Content-Type" "In-Reply-To" "References" "List-Id" "User-Agent" "Thread-Topic" "Thread-Index"];
            algorithm = "rsa-sha256";
            canonicalization = "relaxed/relaxed";
            expire = "10d";
            set-body-length = false;
            report = true;
          };
          ed25519 = {
            private-key = "%{file:${config.sops.secrets."stalwart-mail/SIGNATURE_KEY_ED25519".path}}%";
            domain = "${domain}";
            selector = "ed-default";
            headers = ["From" "To" "Cc" "Date" "Subject" "Message-ID" "Organization" "MIME-Version" "Content-Type" "In-Reply-To" "References" "List-Id" "User-Agent" "Thread-Topic" "Thread-Index"];
            algorithm = "ed25519-sha256";
            canonicalization = "relaxed/relaxed";
            expire = "10d";
            set-body-length = false;
            report = false;
          };
        };
        storage = {
          data = "rocksdb";
          fts = "rocksdb";
          blob = "garage";
          lookup = "rocksdb";
          directory = "internal";
        };
        store."rocksdb" = {
          type = "rocksdb";
          path = "%{env:STALWART_PATH}%/data";
          compression = "lz4";
        };
        store."garage" = {
          type = "s3";
          timeout = "30s";
          bucket = "%{file:${config.sops.secrets."stalwart-mail/S3_BUCKET".path}}%";
          region = "%{file:${config.sops.secrets."stalwart-mail/S3_REGION".path}}%";
          endpoint = "%{file:${config.sops.secrets."stalwart-mail/S3_ENDPOINT".path}}%";
          access-key = "%{file:${config.sops.secrets."stalwart-mail/S3_ACCESS_KEY".path}}%";
          secret-key = "%{file:${config.sops.secrets."stalwart-mail/S3_SECRET_KEY".path}}%";
        };
        directory."internal" = {
          type = "internal";
          store = "rocksdb";
        };
        tracer."stdout" = {
          type = "stdout";
          level = "info";
          ansi = false;
          enable = true;
        };
        tracer."journal" = {
          type = "journal";
          level = "info";
          enable = true;
        };
        authentication."fallback-admin" = {
          user = "admin";
          secret = "%{file:${config.sops.secrets."stalwart-mail/ADMIN_SECRET".path}}%";
        };
      };
    };

    systemd.services.stalwart-mail = {
      environment = {
        STALWART_PATH = "/var/lib/stalwart-mail";
      };
      serviceConfig = {
        StateDirectory = "stalwart-mail";
        StateDirectoryMode = "0740";
      };
    };

    systemd.timers."stalwart-mail-update-certs" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        Unit = "stalwart-mail-update-certs.service";
      };
    };

    systemd.services."stalwart-mail-update-certs" = {
      script = ''
        set -eu

        CADDY_CERT_DIR="/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/${cfg.smtpDomain}"
        STALWART_CERT_DIR="/var/lib/stalwart-mail/cert"

        mkdir -p "''\${CADDY_CERT_DIR}"
        mkdir -p "''\${STALWART_CERT_DIR}"

        cat "''\${CADDY_CERT_DIR}/${cfg.smtpDomain}.crt" > "''\${STALWART_CERT_DIR}/${cfg.smtpDomain}.pem"
        cat "''\${CADDY_CERT_DIR}/${cfg.smtpDomain}.key" > "''\${STALWART_CERT_DIR}/${cfg.smtpDomain}.priv.pem"

        chown -R stalwart-mail:stalwart-mail "''\${STALWART_CERT_DIR}"
        chmod -R 0700 "''\${STALWART_CERT_DIR}"
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };
}
