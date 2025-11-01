{
  flake,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  inherit (flake) inputs;
  cfg = config.gasdev.desktop.udiskr;
in {
  options.gasdev.desktop.udiskr = {
    enable = mkEnableOption "Enable udiskr auto-mount service";
    package = mkOption {
      default = inputs.udiskr.packages.${pkgs.system}.default;
    };
  };

  config = mkIf cfg.enable {
    systemd.user = {
      services.udiskr = {
        Unit = {
          Description = "Lightweight alternative to udiskie";
        };

        Service = {
          Type = "simple";
          ExecStart = "${cfg.package}/bin/udiskr";
        };

        Install = {
          WantedBy = ["default.target"];
        };
      };
    };
  };
}
