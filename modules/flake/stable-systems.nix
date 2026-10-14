{
  lib,
  inputs,
  config,
  ...
}: let
  inherit (inputs) self;
  nixpkgs = inputs.nixpkgs-stable;
  flake = {inherit self inputs config;};
  hm-stable = {
    imports = [
      inputs.home-manager-stable.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {inherit flake;};
      }
    ];
  };
in {
  flake.nixosConfigurations = {
    Zeus = lib.mkForce (nixpkgs.lib.nixosSystem {
      specialArgs = {inherit flake;};
      system = "x86_64-linux";
      modules = [
        "${inputs.nixos-unified}/nix/modules/configurations"
        hm-stable
        ../../configurations/nixos/Zeus
      ];
    });

    Hephaistos = lib.mkForce (nixpkgs.lib.nixosSystem {
      specialArgs = {inherit flake;};
      system = "aarch64-linux";
      modules = [
        "${inputs.nixos-unified}/nix/modules/configurations"
        hm-stable
        ../../configurations/nixos/Hephaistos
      ];
    });
  };
}
