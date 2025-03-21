{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop.apps;
in {
  imports = [
    ./alacritty.nix
    ./firefox.nix
  ];

  options.gasdev.desktop.apps = {
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        vlc
        qbittorrent
        prismlauncher
        element-desktop
        webcord
      ];
    };
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
    };
  };

  config = mkIf config.gasdev.desktop.enable {
    home.packages = cfg.packages + cfg.extraPackages;
  };
}
