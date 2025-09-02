{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop.apps.games;
in {
  imports = [
    ./apps
    ./eww
    ./hypr
    ./misc
    ./niri
  ];

  options.gasdev.desktop.apps.games = {
    enable = mkEnableOption "Enable gaming config";
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        prismlauncher
        vintagestory
        mindustry
      ];
    };
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    home.packages = cfg.defaultPackages ++ cfg.extraPackages;
  };
}
