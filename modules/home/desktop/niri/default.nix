{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop.niri;
  apps = config.gasdev.desktop.apps;
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
    programs.niri.settings = {
      input.keyboard.xkb.layout = "fr";

      binds = {
        "Mod+Return".action.spawn = "${apps.terminal}";
        "Mod+B".action.spawn = "${apps.browser}";
        "Mod+N".action.spawn = "${apps.explorer}";
        "Mod+R".action.spawn = "${apps.launcher}";
      };
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
