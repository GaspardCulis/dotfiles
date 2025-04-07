{
  _inputs,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop.swww;
in {
  options.gasdev.desktop.swww = {
    enable = mkEnableOption "Enable opiniated end-rs service config";
    package = mkPackageOption pkgs "swww" {};
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      SWWW_TRANSITION = "random";
      SWWW_TRANSITION_FPS = "60";
      SWWW_TRANSITION_DURATION = "1.5";
    };

    home.packages = [
      cfg.package
    ];

    services = {
      swww = {
        enable = true;
        package = cfg.package;
      };
    };
  };
}
