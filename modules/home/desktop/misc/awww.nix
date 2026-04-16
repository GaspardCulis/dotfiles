{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop.awww;
in {
  options.gasdev.desktop.awww = {
    enable = mkEnableOption "Enable opiniated awww service config";
    package = mkPackageOption pkgs "awww" {};
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      AWWW_TRANSITION = "random";
      AWWW_TRANSITION_FPS = "60";
      AWWW_TRANSITION_DURATION = "1.5";
    };

    home.packages = [
      cfg.package
    ];

    services = {
      awww = {
        enable = true;
        package = cfg.package;
      };
    };
  };
}
