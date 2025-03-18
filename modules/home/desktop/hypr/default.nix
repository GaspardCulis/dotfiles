{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop.hypr;
in {
  options.gasdev.desktop.hypr = {
    enable = mkEnableOption "Enable opiniated Hyprland config";
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      settings = import ./config.nix {inherit config;};
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      plugins = [inputs.hy3.packages.${pkgs.system}.hy3];
    };

    home.pointerCursor = {
      gtk.enable = true;
      # x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
