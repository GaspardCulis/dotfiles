{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.shell.emulator.alacritty;
in  {
  options.gasdev.shell.emulator.alacritty = {
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
          normal.family = "FiraCode Nerd Font";
          bold.family = "FiraCode Nerd Font";
          italic.family = "FiraCode Nerd Font";
          bold_italic.family = "FiraCode Nerd Font";
        };
        window = {
          opacity = 0.8;
        };
      };
    };
  };  
}
