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

    home.file.".config/eww" = {
      source = ../../../../config/eww;
      recursive = true;
    };

    home.file.".config/eww/theme.scss".text = let
      colors = config.lib.stylix.colors;
    in ''
      /* Theme color variables */
      $base00: #${colors.base00};
      $base01: #${colors.base01};
      $base02: #${colors.base02};
      $base03: #${colors.base03};
      $base04: #${colors.base04};
      $base05: #${colors.base05};
      $base06: #${colors.base06};
      $base07: #${colors.base07};
      $base08: #${colors.base08};
      $base09: #${colors.base09};
      $base0A: #${colors.base0A};
      $base0B: #${colors.base0B};
      $base0C: #${colors.base0C};
      $base0D: #${colors.base0D};
      $base0E: #${colors.base0E};
      $base0F: #${colors.base0F};

      $background: $base00;
      $background-active: $base01;
      $text: $base06;

      $purple: $base0E;
      $blue: $base0D;
      $green: $base0B;
      $yellow: $base0A;
      $orange: $base09;
      $red: $base08;

      $normal: $green;
      $warning: $orange;
      $critical: $red;
    '';

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
          enable ? true,
        }: {
          Unit = {
            Description = "Eww ${name} widget";
            Requires = ["eww.service"];
            After = ["eww.service"];
          };

          Service = {
            Type = "one-shot";
            ExecStart =
              if type == "simple"
              then "${cfg.package}/bin/eww open ${name}"
              else "${cfg.package}/bin/eww open-many ${name}:${name}${toString monitor} --arg ${name}${toString monitor}:monitor=${toString monitor}";
          };

          Install = mkIf enable {
            WantedBy = ["eww.service"];
          };
        };
      in {
        eww = {
          Unit = {
            Description = "ElKowars wacky widgets";
            After = ["graphical-session.target"];
            Requires = ["graphical-session.target"];
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
          monitor = "eDP-1";
        });

        eww-bar-extmon = mkIf cfg.widget.bar.enable (mkWidget {
          name = "bar";
          type = "window";
          monitor = 1;
          enable = false;
        });

        eww-music = mkIf cfg.widget.music.enable (mkWidget {name = "music";});
        eww-timer = mkIf cfg.widget.timer.enable (mkWidget {name = "timer";});
      };
    };
  };
}
