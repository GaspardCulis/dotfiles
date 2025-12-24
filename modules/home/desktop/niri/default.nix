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
        wdisplays
        wl-clipboard-rs
      ];
    };
    xwayland = {
      enable = mkEnableOption "Enable xwayland-satellite integration";
    };
  };

  config = mkIf cfg.enable {
    programs.niri = {
      settings = import ./config.nix {inherit config pkgs;};
    };

    home.packages = cfg.extraPackages;

    programs.bash = mkIf cfg.autoStart {
      initExtra = lib.mkAfter ''
        if [ "$(tty)" = /dev/tty${toString cfg.autoStartTTY} ]; then
          exec ${package}/bin/niri-session
        fi
      '';
    };

    # TODO: Common wayland config ?
    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
