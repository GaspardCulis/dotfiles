{
  options,
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
    deviceScale = mkOption {
      description = "Device scale for HiDPI displays";
      type = types.ints.positive;
      default = 1;
    };
  };

  config = mkIf cfg.enable ({
      boot = {
        plymouth = {
          enable = true;
          theme = "spinner_alt";
          themePackages = with pkgs; [
            # By default we would install all themes
            (adi1090x-plymouth-themes.override {
              selected_themes = ["spinner_alt"];
            })
          ];
          extraConfig = ''
            DeviceScale=${toString cfg.deviceScale}
          '';
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
    }
    // optionalAttrs (builtins.hasAttr "stylix" options) {
      # Yeet stylix
      stylix.targets.plymouth.enable = false;
    });
}
