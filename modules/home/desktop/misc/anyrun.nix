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
  imports = [
    inputs.anyrun.homeManagerModules.anyrun
  ];

  options.gasdev.desktop.anyrun = {
    enable = mkEnableOption "Enable opiniated anyrun config";
    anixrun.enable = mkEnableOption "Enable anixrun extra plugin";
  };

  config = mkIf cfg.enable {
    programs.anyrun = {
      enable = true;
      config = {
        plugins =
          [
            inputs.anyrun.packages.${pkgs.system}.applications
            inputs.anyrun.packages.${pkgs.system}.symbols
            inputs.anyrun.packages.${pkgs.system}.websearch
            inputs.anyrun.packages.${pkgs.system}.rink
            inputs.anyrun.packages.${pkgs.system}.shell
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
      extraCss = builtins.readFile ../../../../misc/anyrun/style.css;

      extraConfigFiles."applications.ron".text = builtins.readFile ../../../../misc/anyrun/applications.ron;
      extraConfigFiles."symbols.ron".text = builtins.readFile ../../../../misc/anyrun/symbols.ron;
      extraConfigFiles."websearch.ron".text = builtins.readFile ../../../../misc/anyrun/websearch.ron;
    };
  };
}
