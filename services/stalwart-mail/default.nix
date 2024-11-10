{config, ...}: let
  domain = "gasdev.fr";
in {
  sops.secrets."stalwart-mail/ADMIN_SECRET".owner = "stalwart-mail";
  sops.secrets."stalwart-mail/ACME_SECRET".owner = "stalwart-mail";

  services.caddy.virtualHosts."mailadmin.${domain}" = {
    extraConfig = ''
      reverse_proxy http://127.0.01:8080
    '';
    serverAliases = [
      "mta-sts.${domain}"
      "autoconfig.${domain}"
      "autodiscover.${domain}"
      "mail.${domain}"
    ];
  };
  networking.firewall.allowedTCPPorts = [25 465 587 993];

  services.stalwart-mail = {
    enable = true;
    settings = {
      server = {
        hostname = "mx1.${domain}";
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
          };
          imaps = {
            bind = "[::]:993";
            protocol = "imap";
          };
          jmap = {
            bind = "[::]:8080";
            url = "https://mail.${domain}";
            protocol = "jmap";
          };
          management = {
            bind = ["127.0.0.1:8080"];
            protocol = "http";
          };
        };
      };
      lookup.default = {
        hostname = "mx1.${domain}";
        domain = "${domain}";
      };
      acme."letsencrypt" = {
        default = true;
        directory = "https://acme-v02.api.letsencrypt.org/directory";
        challenge = "dns-01";
        contact = "postmaster@${domain}";
        domains = ["${domain}" "mx1.${domain}"];
        provider = "cloudflare";
        secret = "%{file:${config.sops.secrets."stalwart-mail/ACME_SECRET".path}}%";
      };
      session.auth = {
        mechanisms = "[plain]";
        directory = "'in-memory'";
      };
      session.rcpt.directory = "'in-memory'";
      queue.outbound.next-hop = "'local'";
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
}
