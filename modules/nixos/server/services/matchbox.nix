{
  config,
  flake,
  pkgs,
  lib,
  ...
}:
with lib; let
  inherit (flake) inputs;
  inherit (inputs) self;

  cfg = config.gasdev.services.matchbox;
  domain = config.gasdev.server.domain;

  matchbox = pkgs.callPackage (self + /packages/matchbox.nix) {};
in {
  options.gasdev.services.matchbox = {
    enable = mkEnableOption "Enable service";
    domain = mkOption {
      type = types.nonEmptyStr;
      description = "Public domain";
      default = "matchbox.${domain}";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Internal port";
      default = 3536;
    };
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."${cfg.domain}".extraConfig = ''
      @websockets {
          path /*
      }

      reverse_proxy @websockets localhost:${toString cfg.port}
    '';

    systemd.services.matchbox = {
      description = "A signaling server for WebRTC peer-to-peer full-mesh networking";
      wants = ["network-online.target"];
      after = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      enable = true;
      serviceConfig = {
        Restart = "always";
        ExecStart = "${matchbox}/bin/matchbox_server 127.0.0.1:${toString cfg.port}";
      };
    };
  };
}
