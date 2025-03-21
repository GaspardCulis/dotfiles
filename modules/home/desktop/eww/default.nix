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
    widget = {
      bar.enable = mkEnableOption "Enable widget auto-start service";
      music.enable = mkEnableOption "Enable widget auto-start service";
      timer.enable = mkEnableOption "Enable widget auto-start service";
    };
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
      services = let
        mkWidget = {
          name,
          type ? "simple",
          monitor ? 0,
        }: {
          Unit = {
            Description = "Eww ${name} widget";
            PartOf = ["graphical-session.target"];
            After = ["eww.service"];
          };

          Service = {
            Type = "one-shot";
            ExecStart =
              if type == "simple"
              then "${cfg.package}/bin/eww open ${name}"
              else "${cfg.package}/bin/eww open-many ${name}:${name}0 --arg ${name}0:monitor=${toString monitor}";
          };

          Install = {
            WantedBy = ["graphical-session.target"];
          };
        };
      in {
        eww = {
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

        eww-bar = mkIf cfg.widget.bar.enable (mkWidget {
          name = "bar";
          type = "window";
          monitor = 0;
        });

        eww-music = mkIf cfg.widget.music.enable (mkWidget {name = "music";});
        eww-timer = mkIf cfg.widget.timer.enable (mkWidget {name = "timer";});
      };
    };
  };
}
