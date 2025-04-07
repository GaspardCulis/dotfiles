{
  config,
  domain,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.nakama;
in {
  options.gasdev.services.nakama = {
    enable = mkEnableOption "Enable service";
    grpcDomain = mkOption {
      type = types.nonEmptyStr;
      description = "Public gRPC API domain";
      default = "grpc.nakama.${domain}";
    };
    apiDomain = mkOption {
      type = types.nonEmptyStr;
      description = "Public HTTP API domain";
      default = "api.nakama.${domain}";
    };
    webDomain = mkOption {
      type = types.nonEmptyStr;
      description = "Public Web console domain";
      default = "console.nakama.${domain}";
    };
    grpcPort = mkOption {
      type = types.ints.unsigned;
      description = "Internal container gRPC port";
      default = 7349;
    };
    apiPort = mkOption {
      type = types.ints.unsigned;
      description = "Internal container HTTP API port";
      default = 7350;
    };
    webPort = mkOption {
      type = types.ints.unsigned;
      description = "Internal container Web console port";
      default = 7351;
    };
  };
  config = mkIf cfg.enable {
    sops.secrets."nakama/DB_PASS".owner = "root";
    sops.secrets."nakama/SERVER_KEY".owner = "root";
    sops.secrets."nakama/ENCRYPTION_KEY".owner = "root";
    sops.secrets."nakama/REFRESH_ENCRYPTION_KEY".owner = "root";
    sops.secrets."nakama/HTTP_KEY".owner = "root";
    sops.secrets."nakama/CONSOLE_USER".owner = "root";
    sops.secrets."nakama/CONSOLE_PASS".owner = "root";
    sops.secrets."nakama/SIGNING_KEY".owner = "root";

    services.caddy.virtualHosts."${cfg.grpcDomain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.grpcPort}
    '';

    services.caddy.virtualHosts."${cfg.apiDomain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.apiPort}
    '';

    services.caddy.virtualHosts."${cfg.webDomain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.webPort}
    '';

    sops.templates."nakama/db.env" = {
      content = ''
        POSTGRES_PASSWORD=${config.sops.placeholder."nakama/DB_PASS"}
      '';
      owner = "root";
    };

    sops.templates."nakama/config.yml" = {
      content = ''
        name: nakama1
        socket:
          server_key: "${config.sops.placeholder."nakama/SERVER_KEY"}"

        session:
          # 6h token expiry
          token_expiry_sec: 21600
          encryption_key: "${config.sops.placeholder."nakama/ENCRYPTION_KEY"}"
          refresh_encryption_key: "${config.sops.placeholder."nakama/REFRESH_ENCRYPTION_KEY"}"

        runtime:
          http_key: "${config.sops.placeholder."nakama/HTTP_KEY"}"

        console:
          username: "${config.sops.placeholder."nakama/CONSOLE_USER"}"
          password: "${config.sops.placeholder."nakama/CONSOLE_PASS"}"

          signing_key: "${config.sops.placeholder."nakama/SIGNING_KEY"}"
      '';
      owner = "root";
    };

    virtualisation.oci-containers.containers = {
      nakama = {
        image = "registry.heroiclabs.com/heroiclabs/nakama:latest";
        pull = "newer";
        autoStart = true;
        ports = [
          "127.0.0.1:${toString cfg.grpcPort}:7349"
          "127.0.0.1:${toString cfg.apiPort}:7350"
          "127.0.0.1:${toString cfg.webPort}:7351"
        ];
        volumes = [
          "nakama-data:/nakama/data"
          "${config.sops.templates."nakama/config.yml".path}:/nakama/data/config.yml"
        ];
        dependsOn = ["nakama-db"];
        environmentFiles = [
          config.sops.templates."nakama/db.env".path
        ];
        entrypoint = "/bin/sh";
        cmd = [
          "-ecx"
          ''
            /nakama/nakama migrate up --config /nakama/data/config.yml --database.address postgres:$POSTGRES_PASSWORD@nakama-db:5432/nakama && exec /nakama/nakama --config /nakama/data/config.yml --database.address postgres:$POSTGRES_PASSWORD@nakama-db:5432/nakama
          ''
        ];
      };

      nakama-db = {
        image = "docker.io/postgres:12.2-alpine";
        pull = "newer";
        autoStart = true;
        volumes = ["nakama-db:/var/lib/postgresql/data"];
        environment = {
          POSTGRES_DB = "nakama";
        };
        environmentFiles = [
          config.sops.templates."nakama/db.env".path
        ];
      };
    };
  };
}
