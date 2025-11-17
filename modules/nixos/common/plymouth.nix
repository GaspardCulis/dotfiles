{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.plymouth;
in {
  options.gasdev.plymouth = {
    enable = mkEnableOption "Enable opiniated boot animation config";
  };

  config = mkIf cfg.enable {
    boot = {
      plymouth = {
        enable = true;
        theme = "angular";
        themePackages = with pkgs; [
          # By default we would install all themes
          (adi1090x-plymouth-themes.override {
            selected_themes = ["angular"];
          })
        ];
      };

      # Enable "Silent boot"
      consoleLogLevel = 3;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
      ];
    };

    # Yeet stylix
    stylix.targets.plymouth.enable = false;
  };
}
