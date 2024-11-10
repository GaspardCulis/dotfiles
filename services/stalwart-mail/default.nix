{config, ...}: let
  domain = "gasdev.fr";
in {
  sops.secrets."stalwart-mail/ADMIN_SECRET".owner = "stalwart-mail";
  sops.secrets."stalwart-mail/ACME_SECRET".owner = "stalwart-mail";

  services.caddy.virtualHosts."mailadmin.${domain}" = {
    extraConfig = ''
      reverse_proxy http://127.0.01:40312
    '';
  };
  services.caddy.virtualHosts."mail.${domain}" = {
    extraConfig = ''
      reverse_proxy http://127.0.01:8080
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
        hostname = "mail.${domain}";
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
            bind = "[::]:8080";
            protocol = "http";
            tls.implicit = false;
          };
          management = {
            bind = ["127.0.0.1:40312"];
            protocol = "http";
          };
        };
      };
      lookup.default = {
        hostname = "mail.${domain}";
        domain = "${domain}";
      };
      certificate.default = {
        default = true;
        cert = "%{file:/var/lib/stalwart-mail/cert/mail.${domain}.pem}%";
        private-key = "%{file:/var/lib/stalwart-mail/cert/mail.${domain}.priv.pem}%";
      };
      session.auth = {
        mechanisms = "[plain, login]";
      };
      directory."imap".lookup.domains = ["${domain}"];
      storage = {
        data = "rocksdb";
        fts = "rocksdb";
        blob = "rocksdb";
        lookup = "rocksdb";
        directory = "internal";
      };
      store."rocksdb" = {
        type = "rocksdb";
        path = "%{env:STALWART_PATH}%/data";
        compression = "lz4";
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

      CADDY_CERT_DIR="/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/mail.${domain}"
      STALWART_CERT_DIR="/var/lib/stalwart-mail/cert"

      mkdir -p "''\${CADDY_CERT_DIR}"
      mkdir -p "''\${STALWART_CERT_DIR}"

      cat "''\${CADDY_CERT_DIR}/mail.${domain}.crt" > "''\${STALWART_CERT_DIR}/mail.${domain}.pem"
      cat "''\${CADDY_CERT_DIR}/mail.${domain}.key" > "''\${STALWART_CERT_DIR}/mail.${domain}.priv.pem"

      chown -R stalwart-mail:stalwart-mail "''\${STALWART_CERT_DIR}"
      chmod -R 0700 "''\${STALWART_CERT_DIR}"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
