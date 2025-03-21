{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop.eww;
in {
  options.gasdev.desktop.eww = {
    enable = mkEnableOption "Enable opiniated eww service config";
    package = mkPackageOption pkgs "eww" {};
  };

  config = mkIf cfg.enable {
    programs.eww = {
      enable = true;
      enableBashIntegration = config.gasdev.shell.bash.enable;
    };

    home.file.".config/eww".source = ../../../../bar/eww;

    home.packages = [
      # Script dependencies
      pkgs.jq
      pkgs.dash
      pkgs.socat
      pkgs.pamixer
      pkgs.libnotify
      pkgs.playerctl
      pkgs.pavucontrol
    ];

    systemd.user = {
      services.eww = {
        Unit = {
          Description = "ElKowars wacky widgets";
          PartOf = ["graphical-session.target"];
        };

        Service = {
          Type = "simple";
          ExecStart = "${cfg.package}/bin/eww daemon --no-daemonize";
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
