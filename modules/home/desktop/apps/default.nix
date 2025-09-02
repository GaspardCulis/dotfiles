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
    ./firefox.nix
    ./software-center.nix
  ];

  options.gasdev.desktop.apps = {
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        imv
        vlc
        kicad
        qbittorrent
        thunderbird
        element-desktop
        libreoffice-fresh
        youtube-music
        webcord
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
