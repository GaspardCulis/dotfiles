{
  flake,
  config,
  lib,
  ...
}:
with lib; let
  inherit (flake) inputs;
  cfg = config.gasdev.desktop.noctalia;
in {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  options.gasdev.desktop.noctalia = {
    enable = mkEnableOption "Enable opiniated service config";
    scale = lib.mkOption {
      description = "The scaling factor of the status bar";
      type = lib.types.float;
      default = 1.0;
    };
    wallpaper = lib.mkOption {
      description = "Wallpaper path";
      type = lib.types.either lib.types.path lib.types.str;
      default = ../../../assets/ricks-toilets.jpg;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.gasdev.desktop.ashell.enable;
        message = "ashell conflicts with noctalia";
      }
      {
        assertion = !config.gasdev.desktop.awww.enable;
        message = "awww conflicts with noctalia";
      }
      {
        assertion = !config.gasdev.desktop.anyrun.enable;
        message = "anyrun conflicts with noctalia";
      }
    ];

    gasdev.desktop.apps.launcherCmd = ["noctalia" "msg" "panel-toggle" "launcher"];

    programs.noctalia = {
      enable = true;

      settings = {
        shell.ui_scale = cfg.scale;

        wallpaper = {
          enabled = true;
          default.path = cfg.wallpaper;
        };
      };
    };
  };
}
