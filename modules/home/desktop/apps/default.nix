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
    ./games
    ./alacritty.nix
    ./discord.nix
    ./firefox.nix
    ./software-center.nix
  ];

  options.gasdev.desktop.apps = {
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        imv
        vlc
        qbittorrent
        thunderbird
        element-desktop
        libreoffice-fresh
        pear-desktop
      ];
    };
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
    };
  };

  config = mkIf config.gasdev.desktop.enable {
    home.packages = cfg.packages ++ cfg.extraPackages;
  };
}
