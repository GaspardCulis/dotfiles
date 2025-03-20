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
    package = mkPackageOption pkgs "swayosd";
  };

  config = mkIf cfg.enable {
    services.swayosd = {
      enable = true;
      package = cfg.package;
      stylePath = "${config.home.homeDirectory}/.config/swayosd/style.css";
    };

    home.file = {
      ".config/swayosd/style.css".text = ''
        window {
          background: #20d7d1;
          opacity: 0.8;
        }
      '';
    };
  };
}
