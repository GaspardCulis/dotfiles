{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop;
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
        type = types.enum ["alacritty"];
        default = "alacritty";
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
        default = cfg.enable;
      };
    };
  };

  config = mkIf cfg.enable {
    gasdev.desktop = {
      anyrun.enable = cfg.apps.launcher == "anyrun";
      apps = {
        alacritty.enable = cfg.apps.terminal == "alacritty";
        firefox.enable = cfg.apps.browser == "firefox";
      };
    };

    home.packages = with pkgs;
      [
        dconf
        xdg-utils
      ]
      ++ lib.optionals (cfg.apps.explorer == "cosmic-files") [pkgs.cosmic-files]
      ++ lib.optionals (cfg.apps.explorer == "nautilus") [pkgs.nautilus];

    fonts.fontconfig.enable = true;

    home.pointerCursor = {
      gtk.enable = true;
      # x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    services = mkIf cfg.applets.enable {
      network-manager-applet.enable = true;
      blueman-applet.enable = true;
    };
  };
}
