{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop.swayosd;
in {
  options.gasdev.desktop.swayosd = {
    enable = mkEnableOption "Enable opiniated SwayOSD service";
    package = mkPackageOption pkgs "swayosd" {};
  };

  config = mkIf cfg.enable {
    services.swayosd = {
      enable = true;
      package = cfg.package;
    };
    #
    # NVIDIA Optimus fix
    systemd.user.services.swayosd.environment = {
      GSK_RENDERER = "gl";
    };
  };
}
