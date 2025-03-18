{
  config,
  _inputs,
  _pkgs,
  lib,
  ...
}:
with lib; let
  _cfg = config.gasdev.desktop;
in {
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
  };

  imports = [
    ./hypr
  ];
}
