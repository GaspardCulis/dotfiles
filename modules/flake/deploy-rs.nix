# Allow using this repo in `nix flake init`
{
  config,
  inputs,
  ...
}: let
  inherit (inputs) self;
  nixpkgs = inputs.nixpkgs-stable;
  deploy-rs = inputs.deploy-rs;

  flake = {inherit self inputs config;};

  home-manager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {inherit flake;};
      }
    ];
  };
in {
  flake = {
    deploy.nodes = {
      OVHCloud = {
        hostname = "gasdev.fr";
        profiles.system = {
          user = "root";
          sshUser = "root";
          sshOpts = ["-p" "22"];
          sudo = "";
          path = deploy-rs.lib.x86_64-linux.activate.nixos (nixpkgs.lib.nixosSystem {
            specialArgs = {inherit flake;};

            modules = [
              home-manager
              ../../configurations/nixos/OVHCloud
            ];
          });
        };
      };

      pi4 = {
        hostname = "10.8.0.31";
        profiles.system = {
          user = "root";
          sshUser = "root";
          sshOpts = ["-p" "22" "-J" "root@gasdev.fr"];
          sudo = "";
          path = deploy-rs.lib.aarch64-linux.activate.nixos (nixpkgs.lib.nixosSystem {
            specialArgs = {inherit flake;};
            system = "aarch64-linux";

            modules = [
              home-manager
              ../../configurations/nixos/pi4
            ];
          });
        };
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
