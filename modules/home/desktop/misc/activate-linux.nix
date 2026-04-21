{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.gasdev.desktop.activate-linux;
in {
  options.gasdev.desktop.activate-linux = {
    enable = lib.mkEnableOption "Enable opiniated end-rs service config";
    package = lib.mkPackageOption pkgs "activate-linux" {};
  };

  config = lib.mkIf cfg.enable {
    systemd.user = {
      services.activate-linux = {
        Unit = {
          Description = "\"Activate Windows\" watermark ported to Linux";
          After = ["graphical-session.target"];
          Requires = ["graphical-session.target"];
        };

        Service = {
          Type = "simple";
          ExecStart = "${cfg.package}/bin/activate-linux";
          Restart = "always";
          RestartSec = "2s";
        };

        Install = {
          WantedBy = ["graphical-session.target"];
        };
      };
    };
  };
}
