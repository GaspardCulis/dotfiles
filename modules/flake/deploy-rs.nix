# Allow using this repo in `nix flake init`
{inputs, ...}: let
  inherit (inputs) self;

  # Nixpkgs used by the target systems. Using stable
  nixpkgs = inputs.nixpkgs-stable;
  # QOL alias
  deploy-rs = inputs.deploy-rs;
  # nixpkgs with deploy-rs overlay but force the nixpkgs package to avoid compilation
  deploy-rs-nixpkgs = system: let
    pkgs = import nixpkgs {inherit system;};
  in (import nixpkgs {
    inherit system;
    overlays = [
      deploy-rs.overlays.default
      (self: super: {
        deploy-rs = {
          inherit (pkgs) deploy-rs;
          lib = super.deploy-rs.lib;
        };
      })
    ];
  });
in {
  flake = {
    deploy.nodes = {
      Zeus = {
        hostname = "gasdev.fr";
        profiles.system = {
          user = "root";
          sshUser = "root";
          sshOpts = ["-p" "22"];
          sudo = "";
          path = (deploy-rs-nixpkgs "x86_64-linux").deploy-rs.lib.activate.nixos self.nixosConfigurations.Zeus;
        };
      };

      Hephaistos = {
        hostname = "10.8.0.31";
        profiles.system = {
          user = "root";
          sshUser = "root";
          sshOpts = ["-p" "22" "-J" "root@gasdev.fr"];
          sudo = "";
          path = (deploy-rs-nixpkgs "aarch64-linux").deploy-rs.lib.activate.nixos self.nixosConfigurations.Hephaistos;
        };
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
