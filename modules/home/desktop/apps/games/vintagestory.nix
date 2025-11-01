{
  config,
  flake,
  pkgs,
  lib,
  ...
}:
with lib; let
  inherit (flake) inputs;
  inherit (inputs) self;

  cfg = config.gasdev.desktop.apps.vintagestory;

  vintagestory = pkgs.callPackage (self + /packages/vintagestory.nix) {};
in {
  options.gasdev.desktop.apps.vintagestory = {
    enable = mkEnableOption "Enable module";
  };

  config = mkIf cfg.enable {
    home.packages = [
      vintagestory
    ];
  };
}
