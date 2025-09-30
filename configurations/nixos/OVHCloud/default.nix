# This file is just *top-level* configuration.
{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.nixosModules.default
    self.nixosModules.server
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    ./configuration.nix
  ];

  nixos-unified.sshTarget = "root@gasdev.fr";
}
