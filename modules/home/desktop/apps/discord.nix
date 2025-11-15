{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop.apps.discord;
in {
  options.gasdev.desktop.apps.discord = {
    enable = mkEnableOption "Enable module";
  };

  config = mkIf cfg.enable {
    programs.vesktop = {
      enable = true;
    };
  };
}
