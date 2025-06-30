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
    enable = mkEnableOption "Enable service";
    settings = {
      metadata_dir = mkOption {
        type = types.nonEmptyStr;
        default = "/var/lib/garage/meta";
      };
      data_dir = mkOption {
        type = types.nonEmptyStr;
        default = "/var/lib/garage/data";
      };
      replication_factor = mkOption {
        type = types.ints.unsigned;
        default = 1;
      };
      bootstrap_peers = mkOption {
        type = types.listOf types.str;
        default = [];
      };
      rpc_public_addr = mkOption {
        type = types.nonEmptyStr;
      };
    };
    expose = mkOption {
      type = types.bool;
      description = "Expose endpoints with caddy";
      default = true;
    };
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public S3 API domain";
      default = "s3.${domain}";
    };
    webDomain = mkOption {
      type = types.nonEmptyStr;
      description = "Public S3 Web API domain";
      default = "s3web.${domain}";
    };
    apiPort = mkOption {
      type = types.ints.unsigned;
      description = "Internal S3 API port";
      default = 3900;
    };
    rpcPort = mkOption {
      type = types.ints.unsigned;
      description = "Internal RPC port";
      default = 3901;
    };
    webPort = mkOption {
      type = types.ints.unsigned;
      description = "Internal Web API port";
      default = 3902;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."garage/RPC_SECRET".owner = "root";

    services.caddy.virtualHosts."${cfg.domain} *.${cfg.domain}" = mkIf cfg.expose {
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

    services.caddy.virtualHosts."${cfg.webDomain} *.${cfg.webDomain}" = mkIf cfg.expose {
      logFormat = "output file ${config.services.caddy.logDir}/access-s3web.gasdev.fr.log";
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.webPort}
      '';
    };

    virtualisation.oci-containers.containers = let
      garage-config = (pkgs.formats.toml {}).generate "garage.toml" {
        metadata_dir = "/var/lib/garage/meta";
        data_dir = "/var/lib/garage/data";
        db_engine = "lmdb";
        metadata_auto_snapshot_interval = "6h";

        replication_factor = cfg.settings.replication_factor;

        bootstrap_peers = cfg.settings.bootstrap_peers;

        compression_level = 2;

        rpc_bind_addr = "[::]:${toString cfg.rpcPort}";
        rpc_public_addr = "${cfg.settings.rpc_public_addr}:${toString cfg.rpcPort}";
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
    in {
      garage = {
        image = "docker.io/dxflrs/garage:v1.1.0";
        pull = "newer";
        autoStart = true;
        extraOptions = [
          "--network=host"
        ];
        volumes = [
          "${garage-config}:/etc/garage.toml"
          "${cfg.settings.data_dir}:/var/lib/garage/data"
          "${cfg.settings.metadata_dir}:/var/lib/garage/meta"
          "/run/secrets/garage/RPC_SECRET:/run/secrets/garage/RPC_SECRET"
        ];
      };
    };

    networking.firewall = {
      allowedTCPPorts = [cfg.rpcPort];
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.settings.metadata_dir} 0700 root root -"
      "d ${cfg.settings.data_dir} 0700 root root -"
    ];

    programs.bash.shellAliases = {
      garage = "podman exec -it garage /garage";
    };
  };
}
