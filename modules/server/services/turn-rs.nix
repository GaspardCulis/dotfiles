{
  config,
  domain,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.services.turn-rs;

  turn-rs = pkgs.rustPlatform.buildRustPackage {
    pname = "turn-rs";
    version = "3.4.0";
    src = builtins.fetchGit {
      url = "https://github.com/mycrl/turn-rs";
      rev = "c292a8e4f255a893a75b06977eaaa38c58cabc6f";
    };
    useFetchCargoVendor = true;
    cargoHash = "sha256-wnbovuxh3wc1TU8BYZEOG/8SO9bCUd0eWRC81MtAdqo=";

    nativeBuildInputs = [
      pkgs.pkg-config
    ];

    buildInputs = [];
  };
in {
  options.gasdev.services.turn-rs = {
    enable = mkEnableOption "Enable service";
    interface = mkOption {
      type = types.nonEmptyStr;
      description = "External interface";
    };
    port = mkOption {
      type = types.ints.unsigned;
      description = "Interface port";
      default = 3478;
    };
    apiPort = mkOption {
      type = types.ints.unsigned;
      description = "REST API port";
      default = 7342;
    };
    openFirewall = mkEnableOption "Open firewall for port";
  };

  config = mkIf cfg.enable {
    systemd.services.turn-rs = let
      config = (pkgs.formats.toml {}).generate "turn-rs.toml" {
        turn = {
          realm = domain;

          interfaces = [
            {
              transport = "udp";
              bind = "${cfg.interface}:${toString cfg.port}";
              external = "${cfg.interface}:${toString cfg.port}";
            }
          ];
        };
      };
    in {
      description = "A pure rust implemented turn server.";
      after = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      enable = true;
      serviceConfig = {
        Restart = "always";
        ExecStart = "${turn-rs}/bin/turn-server --config ${config}";
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.port];
    };
  };
}
