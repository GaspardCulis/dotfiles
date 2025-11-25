{
  flake,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  inherit (flake) inputs;
  cfg = config.gasdev.desktop.end-rs;
in {
  options.gasdev.desktop.end-rs = {
    enable = mkEnableOption "Enable opiniated end-rs service config";
    package = mkOption {
      default = inputs.end-rs.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
  };

  config = mkIf cfg.enable {
    gasdev.desktop.eww.enable = true;

    home.file = {
      ".config/end-rs/config.toml".source = (pkgs.formats.toml {}).generate "end-rs-config.toml" {
        eww_binary_path = "${pkgs.eww}/bin/eww";

        max_notifications = 10;
        notification_orientation = "v";

        timeout = {
          low = 5;
          normal = 10;
          critical = 0;
        };

        icon_theme =
          if config.stylix.polarity == "dark"
          then config.stylix.icons.dark
          else config.stylix.icons.light;
        icon_dirs = [
          "${config.stylix.icons.package}/share/icons"
        ];

        eww_notification_window = "notification_overlay";
        eww_notification_widget = "notification";
        eww_notification_var = "end-notifications";

        eww_history_window = "history-frame";
        eww_history_widget = "end-history";
        eww_history_var = "end-histories";

        eww_reply_window = "reply-frame";
        eww_reply_widget = "end-reply";
        eww_reply_var = "end-replies";
        eww_reply_text = "end-reply-text";
      };
    };

    home.packages = [
      inputs.end-rs
      pkgs.libnotify
    ];

    systemd.user = {
      services.end-rs = {
        Unit = {
          Description = "Eww notification daemon (in Rust)";
          Requires = ["eww.service"];
          After = ["eww.service"];
        };

        Service = {
          Type = "dbus";
          BusName = "org.freedesktop.Notifications";
          ExecStartPre = "${config.gasdev.desktop.eww.package}/bin/eww update end-binary=${cfg.package}/bin/end-rs";
          ExecStart = "${cfg.package}/bin/end-rs daemon";
          Restart = "always";
          RestartSec = "2s";
        };

        Install = {
          WantedBy = ["eww.service"];
        };
      };
    };
  };
}
