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
    };
  };

  config = {
    home.packages = [cfg.theme.font.package] ++ cfg.theme.font.extraPackages;

    fonts.fontconfig.enable = true;
  };
}
