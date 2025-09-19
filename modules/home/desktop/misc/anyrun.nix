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
      extraCss = let
        colors = config.lib.stylix.colors;
      in ''
        #window {
          background-color: transparent;
        }

        box#main {
          border-radius: 10px;
          background-color: #${colors.base00};
          border: 2px solid #${colors.base02};
        }

        list#main {
          background-color: transparent;
        }

        entry#entry {
          margin: 3px;
          border-radius: 20px;
          background: transparent;
        }

        #match {
          padding: 2.5px;
          border-radius: 4px;
        }

        #match:selected {
          background: #${colors.base01};
          border-right: 4px solid #${colors.base0C};
          border-left: 4px solid #${colors.base0C};
          color: #${colors.base07};
        }

        #match:selected label#info {
          animation: fade 0.1s linear;
        }

        @keyframes fade {
          0% {
            color: transparent;
          }

          100% {
            color: #b0b0b0;
          }
        }

        #match label#info {
          color: transparent;
        }

        #match:hover {
          background: #${colors.base01};
        }
      '';

      extraConfigFiles."applications.ron".text = builtins.readFile ../../../../config/anyrun/applications.ron;
      extraConfigFiles."symbols.ron".text = builtins.readFile ../../../../config/anyrun/symbols.ron;
      extraConfigFiles."websearch.ron".text = builtins.readFile ../../../../config/anyrun/websearch.ron;
    };
  };
}
