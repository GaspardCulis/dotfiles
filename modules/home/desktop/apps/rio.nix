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

        developer.log-level = "WARN";

        env-vars = ["TERM=xterm-256color"];

        bell = {
          visual = true;
          audio = false;
        };

        editor = {
          program = lib.getExe config.programs.helix.package;
          args = [];
        };

        hints = {
          alphabet = "jfkdls;ahgurieowpq";
          rules = [
            {
              regex = "(https://|http://)[^\\u0000-\\u001F\\u007F-\\u009F<>\"\\s{-}\\^⟨⟩`\\\\]+";
              hyperlinks = true;
              post-processing = true;

              action = {
                command = "xdg-open";
              };
              binding = {
                key = "O";
                mods = ["Control" "Shift"];
              };
              mouse = {
                enabled = true;
                mods = ["Control"];
              };
            }
          ];
        };

        window = {
          opacity = lib.mkForce 0.8;
          blur = true;
        };
      };
    };
  };
}
