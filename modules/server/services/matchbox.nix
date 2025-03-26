{
  config,
  domain,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.matchbox;

  matchbox_src = pkgs.fetchFromGitHub {
    owner = "johanhelsing";
    repo = "matchbox";
    rev = "v0.11.0";
    hash = "sha256-fF6SeZhfOkyK1hAWxdcXjf6P6pVJWLlkIUtyGxVrm94=";
  };

  matchbox = pkgs.rustPlatform.buildRustPackage {
    pname = "matchbox_server";
    version = "0.11.0";
    src = matchbox_src;
    useFetchCargoVendor = true;
    cargoHash = "sha256-ELA9+wTFYxiuG/QLb0oxN5KfVSalWKmKEvzRlxNHQnw=";

    nativeBuildInputs = [
      pkgs.pkg-config
    ];

    buildInputs = [];
  };
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
      reverse_proxy http://127.0.0.1:${toString cfg.port}
    '';

    systemd.services.matchbox = {
      description = "A signaling server for WebRTC peer-to-peer full-mesh networking";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      enable = true;
      serviceConfig = {
        Restart = "always";
        ExecStart = "${matchbox}/bin/matchbox_server 127.0.0.1:${toString cfg.port}";
      };
    };
  };
}
