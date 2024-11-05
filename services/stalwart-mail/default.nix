{config, ...}: let
  domain = "mail.gasdev.fr";
in {
  sops.secrets."stalwart-mail/ADMIN_SECRET".owner = "stalwart-mail";

  services.caddy.virtualHosts."${domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:8080
  '';

  services.stalwart-mail = {
    enable = true;
    settings = {
      lookup.default.hostname = "${domain}";
      server = {
        tls.certificate = "default";
        http = {
          url = "protocol + '://' + key_get('default', 'hostname') + ':' + local_port";
          use-x-forwarded = true;
        };
        listener = {
          smtp = {
            bind = ["[::]:25"];
            protocol = "smtp";
          };
          submissions = {
            bind = ["[::]:465"];
            protocol = "smtp";
            tls.implicit = true;
          };
          imaptls = {
            bind = ["[::]:993"];
            protocol = "imap";
            tls.implicit = true;
          };
          management = {
            bind = "[::]:8080";
            protocol = "http";
          };
        };
      };
      certificate.default = {
        default = true;
        cert = "%{file:/var/lib/stalwart-mail/cert/${domain}.pem}%";
        private-key = "%{file:/var/lib/stalwart-mail/cert/${domain}.priv.pem}%";
      };
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

  networking.firewall.allowedTCPPorts = [22 465 993];

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

      CADDY_CERT_DIR="/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/${domain}"
      STALWART_CERT_DIR="/var/lib/stalwart-mail/cert"

      mkdir -p "''\${CADDY_CERT_DIR}"
      mkdir -p "''\${STALWART_CERT_DIR}"

      cat "''\${CADDY_CERT_DIR}/${domain}.crt" > "''\${STALWART_CERT_DIR}/${domain}.pem"
      cat "''\${CADDY_CERT_DIR}/${domain}.key" > "''\${STALWART_CERT_DIR}/${domain}.priv.pem"

      chown -R stalwart-mail:stalwart-mail "''\${STALWART_CERT_DIR}"
      chmod -R 0600 "''\${STALWART_CERT_DIR}"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
