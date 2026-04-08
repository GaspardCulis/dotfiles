# This file is just *top-level* configuration.
{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  config.stylix.overlays.enable = false;

  imports = [
    inputs.stylix.nixOnDroidModules.stylix
    ./configuration.nix
  ];
}
