# This file is just *top-level* configuration.
{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.nixosModules.default
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
    inputs.stylix.nixosModules.stylix
    inputs.niri-flake.nixosModules.niri
    inputs.noctalia-greeter.nixosModules.default
    ./configuration.nix
  ];

  nixpkgs.overlays = [
    inputs.nixos-apple-silicon.overlays.apple-silicon-overlay
    inputs.niri-flake.overlays.niri
  ];
}
