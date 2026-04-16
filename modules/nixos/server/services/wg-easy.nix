{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.wg-easy;
  domain = config.gasdev.server.domain;
in {
  options.gasdev.services.wg-easy = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "vpn.${domain}";
    };
    wgPort = mkOption {
      type = types.ints.unsigned;
      description = "Wireguard port, will be exposed";
      default = 4500;
    };
    webPort = mkOption {
      type = types.ints.unsigned;
      description = "Internal web interface port";
      default = 3649;
    };
    ipv4 = mkOption {
      type = types.nonEmptyStr;
      description = "Init IPv4 cidr";
      default = "10.8.0.0/24";
    };
    amnezia = mkEnableOption "Enable AmneziaWG support";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.networking.nat.enable;
        message = "NAT should be enabled when using this module";
      }
    ];

    sops.secrets."wg-easy/INIT_USERNAME".owner = "root";
    sops.secrets."wg-easy/INIT_PASSWORD".owner = "root";

    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString cfg.webPort}
    '';

    sops.templates."wg-easy.env" = {
      content = ''
        INIT_USERNAME=${config.sops.placeholder."wg-easy/INIT_USERNAME"}
        INIT_PASSWORD=${config.sops.placeholder."wg-easy/INIT_PASSWORD"}
      '';
      owner = "root";
    };

    virtualisation.oci-containers.containers = {
      wg-easy = {
        image = "ghcr.io/wg-easy/wg-easy:15";
        pull = "newer";
        autoStart = true;
        volumes = [
          "wg-easy-etc:/etc/wireguard"
          "/run/current-system/kernel-modules:/lib/modules:ro"
        ];
        ports = [
          "127.0.0.1:${toString cfg.webPort}:80"
          "${toString cfg.wgPort}:${toString cfg.wgPort}/udp"
          "${toString cfg.wgPort}:${toString cfg.wgPort}/tcp"
        ];
        environment = {
          PORT = "80";

          INIT_ENABLED = "true";
          INIT_HOST = cfg.domain;
          INIT_PORT = toString cfg.wgPort;
          INIT_IPV4_CIDR = cfg.ipv4;

          EXPERIMENTAL_AWG = toString cfg.amnezia;
        };
        environmentFiles = [
          config.sops.templates."wg-easy.env".path
        ];

        capabilities = {
          NET_ADMIN = true;
          SYS_MODULE = true;
          NET_RAW = true;
        };
        extraOptions = [
          "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
          "--sysctl=net.ipv4.ip_forward=1"
          "--sysctl=net.ipv6.conf.all.disable_ipv6=0"
          "--sysctl=net.ipv6.conf.all.forwarding=1"
          "--sysctl=net.ipv6.conf.default.forwarding=1"
        ];
      };
    };

    boot.kernelModules = [
      "wireguard"
      "ip_tables"
      "iptable_nat"
      "ip6_tables"
      "ip6table_nat"
    ];

    networking.firewall = {
      allowedUDPPorts = [
        cfg.wgPort
      ];
      allowedTCPPorts = [
        cfg.wgPort
      ];
    };
  };
}
