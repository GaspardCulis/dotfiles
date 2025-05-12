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
    ./apps
    ./eww
    ./hypr
    ./misc
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
        type = types.enum ["cosmic-files"];
        default = "cosmic-files";
      };
      launcher = mkOption {
        description = "Default quick launcher app";
        type = types.enum ["anyrun"];
        default = "anyrun";
      };
    };
    theme = {
      color-scheme = mkOption {
        description = "Default color scheme name";
        type = types.enum ["light" "dark"];
        default = "light";
      };
      font = {
        name = mkOption {
          description = "Default font name";
          type = types.str;
          default = "FiraCode Nerd Font";
        };
        package = mkOption {
          type = types.package;
          default = pkgs.nerd-fonts.fira-code;
        };
        extraPackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [pkgs.fira-code-symbols];
        };
      };
      icons = {
        name = mkOption {
          description = "Default icon pack name";
          type = types.str;
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
          type = types.str;
          default = "WhiteSur-Dark-solid-nord";
        };
        package = mkPackageOption pkgs "whitesur-gtk-theme" {};
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

    home.packages =
      [
        pkgs.dconf

        cfg.theme.font.package
        cfg.theme.icons.package
      ]
      ++ cfg.theme.font.extraPackages
      ++ cfg.theme.icons.extraPackages
      ++ (
        if cfg.apps.explorer == "cosmic-files"
        then [pkgs.cosmic-files]
        else []
      );

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme =
          if cfg.theme.color-scheme == "light"
          then "prefer-light"
          else "prefer-dark";
      };
    };

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
