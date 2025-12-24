{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop.hypr;
in {
  options.gasdev.desktop.hypr = {
    enable = mkEnableOption "Enable opiniated Hyprland config";
    autoStart = mkEnableOption "Enable Hyprland autostart on tty";
    autoStartTTY = mkOption {
      type = types.ints.unsigned;
      description = "TTY to autostart on";
      default = 1;
    };
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        egl-wayland # For NVIDIA compatibility
        wdisplays
      ];
    };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      settings = import ./config.nix {inherit config;};
      plugins = with pkgs; [hyprlandPlugins.hy3];
    };

    home.packages = with pkgs;
      [
        # Required packages
        brightnessctl
        playerctl
        grim
        slurp
        hyprpicker
        wl-clipboard
        swaylock-effects
        networkmanagerapplet
      ]
      ++ cfg.extraPackages;

    programs.bash = mkIf cfg.autoStart {
      initExtra = lib.mkAfter ''
        if [ "$(tty)" = /dev/tty${toString cfg.autoStartTTY} ]; then
          exec ${config.wayland.windowManager.hyprland.package}/bin/Hyprland
        fi
      '';
    };

    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
