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
    package = mkPackageOption pkgs "eww";
  };

  config = mkIf cfg.enable {
    programs.eww = {
      enable = true;
      enableBashIntegration = config.gasdev.shell.bash.enable;
    };

    home.file.".config/eww".source = ../../../../bar/eww;

    home.packages = [
      # Script dependencies
      pkgs.jq
      pkgs.dash
      pkgs.socat
      pkgs.pamixer
      pkgs.playerctl
      pkgs.pavucontrol
    ];
  };
}
