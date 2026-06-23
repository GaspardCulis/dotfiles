{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop;

  nautilus-icd-patch = pkgs.symlinkJoin {
    name = "nautilus-icd-patch";
    paths = [
      (
        # Fix dGPU usage on Optimus laptops
        pkgs.writeScriptBin "nautilus" ''
          #!/bin/sh
          icd=/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json
          if [ -f $icd ]; then
            export VK_DRIVER_FILES=/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json
          fi
          exec ${pkgs.nautilus}/bin/nautilus "$@"
        ''
      )
      pkgs.nautilus
    ];
  };
in {
  imports = [
    ./apps
    ./eww
    ./hypr
    ./misc
    ./niri
    ./ashell.nix
  ];

  options.gasdev.desktop = {
    enable = mkEnableOption "Enable desktop config";

    apps = {
      terminal = mkOption {
        description = "Default terminal emulator app";
        type = types.enum ["alacritty" "rio"];
        default = "rio";
      };
      browser = mkOption {
        description = "Default web browser app";
        type = types.enum ["firefox"];
        default = "firefox";
      };
      explorer = mkOption {
        description = "Default file explorer app";
        type = types.enum ["cosmic-files" "nautilus"];
        default = "nautilus";
      };
      launcher = mkOption {
        description = "Default quick launcher app";
        type = types.enum ["anyrun"];
        default = "anyrun";
      };
    };
    applets = {
      enable = mkOption {
        description = "Enable default applet services";
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf cfg.enable {
    gasdev.desktop = {
      anyrun = mkIf (cfg.apps.launcher == "anyrun") {
        enable = true;
        daemon = true;
      };

      apps = {
        alacritty.enable = cfg.apps.terminal == "alacritty";
        rio.enable = cfg.apps.terminal == "rio";
        firefox.enable = cfg.apps.browser == "firefox";
      };
    };

    home.packages = with pkgs;
      [
        dconf
        xdg-utils
      ]
      ++ lib.optionals (cfg.apps.explorer == "cosmic-files") [pkgs.cosmic-files]
      ++ lib.optionals (cfg.apps.explorer == "nautilus") [nautilus-icd-patch];

    fonts.fontconfig.enable = true;

    home.pointerCursor = {
      gtk.enable = true;
      # x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    services =
      (mkIf cfg.applets.enable {
        network-manager-applet.enable = true;
        blueman-applet.enable = true;
      })
      // {
        mpris-proxy.enable = true;
      };
  };
}
