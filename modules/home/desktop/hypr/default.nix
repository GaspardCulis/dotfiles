{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop.hypr;
  package = inputs.hyprland.packages.${pkgs.system}.hyprland;
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
        xdg-utils
        wdisplays
      ];
    };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      settings = import ./config.nix {inherit config;};
      package = package;
      plugins = [inputs.hy3.packages.${pkgs.system}.hy3];
    };

    gasdev.desktop = {
      swayosd.enable = true;
      end-rs.enable = true;
      swww.enable = true;
      eww = {
        enable = true;
        widget = {
          bar.enable = true;
          music.enable = true;
          timer.enable = true;
        };
      };
    };

    services = {
      udiskie.enable = true;
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
          exec ${package}/bin/Hyprland
        fi
      '';
    };

    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
