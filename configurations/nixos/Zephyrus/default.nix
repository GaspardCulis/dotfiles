# This file is just *top-level* configuration.
{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.stylix.nixosModules.stylix
    inputs.niri-flake.nixosModules.niri
    ./configuration.nix
  ];

  nixpkgs.overlays = [inputs.niri-flake.overlays.niri];
}
