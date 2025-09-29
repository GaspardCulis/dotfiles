{
  config,
  domain,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.beszel;
in {
  options.gasdev.services.beszel = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "monitor.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal port";
      default = 8090;
    };
    agent = {
      enable = mkEnableOption "Enable service";
      usePodman = mkEnableOption "Use the Podman API instead of the Docker one";
      openFirewall = mkEnableOption "Open firewall for SSH connections";
      address = mkOption {
        type = types.nonEmptyStr;
        description = "Address to bind to";
        default = "127.0.0.1";
      };
      port = mkOption {
        type = types.ints.unsigned;
        description = "Internal port";
        default = 45876;
      };
      key = mkOption {
        type = types.nonEmptyStr;
        description = "Public key";
      };
      extraFilesystems = mkOption {
        type = types.listOf types.str;
        description = "Extra filesystems to be monitored";
      };
    };
  };

  config = {
    services.caddy.virtualHosts."${cfg.domain}".extraConfig = mkIf cfg.enable ''
      reverse_proxy http://127.0.0.1:${toString cfg.port}
    '';

    virtualisation.oci-containers.containers = mkIf cfg.enable {
      beszel-admin = {
        image = "docker.io/henrygd/beszel";
        pull = "newer";
        autoStart = true;
        extraOptions = [
          "--network=host" # Allows connections to localhost agent
        ];
        ports = [
          "127.0.0.1:${toString cfg.port}:8090"
        ];
        volumes = [
          "beszel_data:/beszel_data"
        ];
      };
    };

    systemd.services.beszel-agent = mkIf cfg.agent.enable {
      enable = true;
      description = "Lightweight server monitoring platform";
      environment =
        mkIf cfg.agent.usePodman
        {
          DOCKER_HOST = "unix:///var/run/podman/podman.sock";
        }
        // (optionalAttrs (builtins.hasAttr "extraFilesystems" cfg.agent) {
          EXTRA_FILESYSTEMS = builtins.concatStringsSep "," cfg.agent.extraFilesystems;
        });
      wants = ["network-online.target"];
      after = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Group = mkIf cfg.agent.usePodman "podman";
        Restart = "always";
        ExecStart = ''
          ${pkgs.beszel}/bin/beszel-agent -key "${cfg.agent.key}" -listen "${cfg.agent.address}:${toString cfg.agent.port}"
        '';
      };
    };

    networking.firewall = mkIf cfg.agent.openFirewall {
      allowedTCPPorts = [cfg.agent.port];
    };
  };
}
