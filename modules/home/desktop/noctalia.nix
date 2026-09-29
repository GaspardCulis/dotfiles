{
  flake,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  inherit (flake) inputs;
  cfg = config.gasdev.desktop.ashell;
in {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  options.gasdev.desktop.noctalia = {
    enable = mkEnableOption "Enable opiniated service config";
    scale = lib.mkOption {
      description = "The scaling factor of the status bar";
      type = lib.types.float;
      default = 1.0;
    };
  };

  config = mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
    };
  };
}
