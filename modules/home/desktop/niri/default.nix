{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop.niri;
  package = config.programs.niri.package;
in {
  options.gasdev.desktop.niri = {
    enable = mkEnableOption "Enable opiniated Niri config";
    autoStart = mkEnableOption "Enable Niri autostart on tty";
    autoStartTTY = mkOption {
      type = types.ints.unsigned;
      description = "TTY to autostart on";
      default = 1;
    };
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        xdg-utils
        wdisplays
      ];
    };
  };

  config = mkIf cfg.enable {
    programs.niri = {
      settings = import ./config.nix {inherit config;};
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

    programs.bash = mkIf cfg.autoStart {
      initExtra = lib.mkAfter ''
        if [ "$(tty)" = /dev/tty${toString cfg.autoStartTTY} ]; then
          exec ${package}/bin/niri
        fi
      '';
    };
  };
}
