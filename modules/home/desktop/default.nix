{
  config,
  _inputs,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop;
in {
  imports = [
    ./hypr
  ];

  options.gasdev.desktop = {
    enable = mkEnableOption "Enable desktop config";

    apps = {
      terminal = mkOption {
        description = "Default terminal emulator app";
        type = types.string;
        default = "alacritty";
      };
      browser = mkOption {
        description = "Default web browser app";
        type = types.string;
        default = "firefox";
      };
      explorer = mkOption {
        description = "Default file explorer app";
        type = types.string;
        default = "kitty --class=explorer yazi";
      };
      launcher = mkOption {
        description = "Default quick launcher app";
        type = types.string;
        default = "anyrun";
      };
    };
    theme = {
      font = {
        name = mkOption {
          description = "Default font name";
          type = types.string;
          default = "FiraCode Nerd Font";
        };
        package = mkPackageOption pkgs "fira-code-nerdfont" {};
        extraPackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [pkgs.fira-code-symbols];
        };
      };
      icons = {
        name = mkOption {
          description = "Default icon pack name";
          type = types.string;
          default = "WhiteSur";
        };
        package = mkPackageOption pkgs "whitesur-icon-theme" {};
        extraPackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [];
        };
      };
      gtk = {
        name = mkOption {
          description = "Default GTK theme";
          type = types.string;
          default = "WhiteSur-Dark-solid-nord";
        };
        package = mkPackageOption pkgs "whitesur-gtk-theme" {};
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      [
        cfg.theme.font.package
        cfg.theme.icons.package
      ]
      ++ cfg.theme.font.extraPackages
      ++ cfg.theme.icons.extraPackages;

    fonts.fontconfig.enable = true;

    gtk = {
      enable = true;
      theme = {
        package = cfg.theme.gtk.package;
        name = cfg.theme.gtk.name;
      };
      iconTheme = {
        package = cfg.theme.icons.package;
        name = cfg.theme.icons.name;
      };
    };
  };
}
