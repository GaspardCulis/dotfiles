{
  config,
  flake,
  pkgs,
  lib,
  ...
}:
with lib; let
  inherit (flake) inputs;
  cfg = config.gasdev.desktop.anyrun;
  anyrun-icd-patch = pkgs.symlinkJoin {
    name = "anyrun-icd-patch";
    paths = [
      (
        # Fix dGPU usage on Optimus laptops: https://github.com/anyrun-org/anyrun/issues/254
        pkgs.writeScriptBin "anyrun" ''
          #!/bin/sh
          export VK_DRIVER_FILES=/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json
          exec ${pkgs.anyrun}/bin/anyrun "$@"
        ''
      )
      pkgs.anyrun
    ];
  };
in {
  options.gasdev.desktop.anyrun = {
    enable = mkEnableOption "Enable opiniated anyrun config";
    package = lib.mkOption {
      type = lib.types.package;
      default = anyrun-icd-patch;
    };
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
            then [inputs.anixrun.packages.${pkgs.stdenv.hostPlatform.system}.default]
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

        .matches {
          background-color: transparent;
        }

        text {
          min-height: 30px;
          padding: 5px;
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
