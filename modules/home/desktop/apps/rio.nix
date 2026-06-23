{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop.apps.rio;
in {
  options.gasdev.desktop.apps.rio = {
    enable = mkEnableOption "Enable module";
  };

  config = mkIf cfg.enable {
    programs.rio = {
      enable = true;
      settings = {
        confirm-before-quit = false;
        copy-on-select = false;

        bindings.keys = [
          {
            key = "left";
            "with" = "control";
            action = "SelectPrevSplit";
          }
          {
            key = "right";
            "with" = "control";
            action = "SelectNextSplit";
          }
        ];

        cursor = {
          shape = "beam";
          blinking = true;
          blinking-interval = 600;
        };

        bell = {
          visual = true;
          audio = false;
        };

        editor = {
          program = lib.getExe config.programs.helix.package;
          args = [];
        };

        window = {
          opacity = lib.mkForce 0.8;
        };
      };
    };
  };
}
