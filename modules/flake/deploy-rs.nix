# Allow using this repo in `nix flake init`
{inputs, ...}: let
  inherit (inputs) self;
  # QOL alias
  deploy-rs = inputs.deploy-rs;
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
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.Zeus;
        };
      };

      Hephaistos = {
        hostname = "10.8.0.31";
        profiles.system = {
          user = "root";
          sshUser = "root";
          sshOpts = ["-p" "22" "-J" "root@gasdev.fr"];
          sudo = "";
          path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.Hephaistos;
        };
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
