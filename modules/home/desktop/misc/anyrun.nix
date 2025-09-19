{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.gasdev.desktop.anyrun;
in {
  options.gasdev.desktop.anyrun = {
    enable = mkEnableOption "Enable opiniated anyrun config";
    package = mkPackageOption pkgs "anyrun" {};
    anixrun.enable = mkEnableOption "Enable anixrun extra plugin";
  };

  config = mkIf cfg.enable {
    programs.anyrun = {
      enable = true;
      package = cfg.package;
      config = {
        plugins =
          [
            "${cfg.package}/lib/libapplications.so"
            "${cfg.package}/lib/libsymbols.so"
            "${cfg.package}/lib/libwebsearch.so"
            "${cfg.package}/lib/librink.so"
            "${cfg.package}/lib/libshell.so"
          ]
          ++ (
            if cfg.anixrun.enable
            then [inputs.anixrun.packages.${pkgs.system}.default]
            else []
          );
        x = {fraction = 0.5;};
        y = {fraction = 0.3;};
        width = {fraction = 0.3;};
        hideIcons = false;
        ignoreExclusiveZones = false;
        layer = "top";
        hidePluginInfo = true;
        closeOnClick = true;
        showResultsImmediately = false;
        maxEntries = null;
      };
      extraCss = ''
        window {
          background-color: transparent;
        }

        box.main {
          padding: 5px;
          border-radius: 10px;
          border: 2px solid @theme_selected_bg_color;
          background-color: @theme_bg_color;
          box-shadow: 0 0 5px black;
        }

        text {
          min-height: 30px;
          padding: 5px;
          border-radius: 5px;
        }

        .matches {
          background-color: transparent;
        }

        entry.entry {
          margin: 3px;
          border-radius: 20px;
          background: transparent;
        }

        .match {
          padding: 2.5px;
          border-radius: 4px;
        }

        .match:selected {
          background: @theme_bg_color;
          border-right: 4px solid @theme_selected_bg_color;
          border-left: 4px solid @theme_selected_bg_color;
        }

        .match:selected label.info {
          animation: fade 0.1s linear;
        }

        .match label.info {
          color: transparent;
        }

        .match:hover {
          background: @theme_bg_color;
        }
      '';

      extraConfigFiles."applications.ron".text = builtins.readFile ../../../../config/anyrun/applications.ron;
      extraConfigFiles."symbols.ron".text = builtins.readFile ../../../../config/anyrun/symbols.ron;
      extraConfigFiles."websearch.ron".text = builtins.readFile ../../../../config/anyrun/websearch.ron;
    };
  };
}
