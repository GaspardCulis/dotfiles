{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop.apps.alacritty;
in {
  options.gasdev.desktop.apps.alacritty = {
    enable = mkEnableOption "Enable module";
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        bell = {
          animation = "EaseOutExpo";
          color = "#440000";
          duration = 50;
        };
        cursor = {
          blink_interval = 600;
          vi_mode_style = "Block";
          style = {
            blinking = "On";
            shape = "Beam";
          };
        };
        env = {
          TERM = "alacritty";
        };
        font = {
          size = 10.0;
          normal.family = config.gasdev.desktop.theme.font.name;
          bold.family = config.gasdev.desktop.theme.font.name;
          italic.family = config.gasdev.desktop.theme.font.name;
          bold_italic.family = config.gasdev.desktop.theme.font.name;
        };
        window = {
          opacity = 0.8;
        };
      };
    };
  };
}
