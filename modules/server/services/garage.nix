{
  config,
  domain,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.garage;
in {
  options.gasdev.services.garage = {
    enable = mkEnableOption "Enable Garage service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Defines the domain on which the S3 API is served.";
      default = "s3.${domain}";
    };
    webDomain = mkOption {
      type = types.nonEmptyStr;
      description = "Defines the domain on which the Web S3 API is served.";
      default = "s3web.${domain}";
    };
    apiPort = mkOption {
      type = types.ints.unsigned;
      description = "Defines the port on which the S3 API runs on.";
      default = 3900;
    };
    rpcPort = mkOption {
      type = types.ints.unsigned;
      description = "Defines the port on which the RPC API runs on.";
      default = 3901;
    };
    webPort = mkOption {
      type = types.ints.unsigned;
      description = "Defines the port on which the Web S3 API runs on.";
      default = 3902;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."garage/RPC_SECRET".owner = "root";

    services.caddy.virtualHosts."${cfg.domain} *.${cfg.domain}" = {
      logFormat = "output file ${config.services.caddy.logDir}/access-${cfg.domain}.log";
      extraConfig = ''
        header {
          ?Access-Control-Allow-Headers *
          ?Access-Control-Allow-Methods *
          ?Access-Control-Allow-Origin *
        }
        reverse_proxy http://127.0.0.1:${toString cfg.apiPort}
      '';
    };

    services.caddy.virtualHosts."${cfg.webDomain} *.${cfg.webDomain}" = {
      logFormat = "output file ${config.services.caddy.logDir}/access-s3web.gasdev.fr.log";
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.webPort}
      '';
    };

    virtualisation.oci-containers.containers = {
      garage = {
        image = "docker.io/dxflrs/garage:v1.0.0";
        pull = "newer";
        autoStart = true;
        ports = [
          "127.0.0.1:${toString cfg.apiPort}:3900"
          "127.0.0.1:${toString cfg.rpcPort}:3901"
          "127.0.0.1:${toString cfg.webPort}:3902"
        ];
        volumes = [
          "/etc/garage.toml:/etc/garage.toml"
          "/var/lib/garage/meta:/var/lib/garage/meta"
          "/var/lib/garage/data:/var/lib/garage/data"
          "/run/secrets/garage/RPC_SECRET:/run/secrets/garage/RPC_SECRET"
        ];
      };
    };

    environment.etc."garage.toml".source = (pkgs.formats.toml {}).generate "garage-config.toml" {
      metadata_dir = "/var/lib/garage/meta";
      data_dir = "/var/lib/garage/data";
      db_engine = "lmdb";
      metadata_auto_snapshot_interval = "6h";

      replication_factor = 1;

      compression_level = 2;

      rpc_bind_addr = "[::]:${toString cfg.rpcPort}";
      rpc_public_addr = "0.0.0.0:${toString cfg.rpcPort}";
      rpc_secret_file = "/run/secrets/garage/RPC_SECRET";

      s3_api = {
        s3_region = "garage";
        api_bind_addr = "[::]:${toString cfg.apiPort}";
        root_domain = ".${cfg.domain}";
      };
      s3_web = {
        bind_addr = "[::]:${toString cfg.webPort}";
        root_domain = ".${cfg.webDomain}";
        index = "index.html";
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/garage/meta 0700 root root -"
      "d /var/lib/garage/data 0700 root root -"
    ];

    programs.bash.shellAliases = {
      garage = "podman exec -it garage /garage";
    };
  };
}
