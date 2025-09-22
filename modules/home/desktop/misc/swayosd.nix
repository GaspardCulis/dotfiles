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
      # GSK_RENDERER = "gl";
      VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
    };
  };
}
