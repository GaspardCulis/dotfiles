{
  description = "Configuration Home Manager jaajesque";

  inputs = {
    # Common
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Server
    caddy.url = "github:GaspardCulis/nixos-caddy-ovh";
    deploy-rs.url = "github:serokell/deploy-rs";
    disko.url = "github:nix-community/disko";
    sops-nix.url = "github:Mic92/sops-nix";

    # Desktop
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-flake = {
      url = "github:sodiboo/niri-flake";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    end-rs = {
      url = "github:Dr-42/end-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    anixrun = {
      url = "github:GaspardCulis/anixrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jaaj-rs = {
      url = "git+https://git.ahur.ac/Jaaj-San/jaaj-rs?rev=e5e5596e85e57ec8a0c4aeb34f64c423320c532d";
      # inputs.nixpkgs.follows = "nixpkgs"; # Take advantage of gasdev cachix
    };

    udiskr = {
      url = "github:00-KAMIDUKI/udiskr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SteamOS
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    suyu = {
      url = "github:Noodlez1232/suyu-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    disko,
    deploy-rs,
    home-manager,
    stylix,
    jovian,
    niri-flake,
    nixos-hardware,
    sops-nix,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in rec {
    nixosConfigurations = {
      Zephyrus = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/Zephyrus
          ./modules/system
          disko.nixosModules.disko
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          jovian.nixosModules.jovian
          niri-flake.nixosModules.niri
        ];
      };

      OVHCloud = let
        domain = "gasdev.fr";
      in
        nixpkgs-stable.lib.nixosSystem {
          specialArgs = {inherit inputs domain;};
          modules = [
            ./hosts/OVHCloud
            ./modules/system
            ./modules/server
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
          ];
        };

      pi4 = let
        domain = "pi.gasdev.fr";
      in
        nixpkgs-stable.lib.nixosSystem {
          specialArgs = {inherit inputs domain;};
          system = "aarch64-linux";
          modules = [
            ./hosts/pi4
            ./modules/system
            ./modules/server
            "${nixpkgs}/nixos/modules/profiles/minimal.nix"
            nixos-hardware.nixosModules.raspberry-pi-4
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
          ];
        };
    };

    homeConfigurations = {
      "gaspard" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {inherit inputs;};
        modules = [
          niri-flake.homeModules.niri
          stylix.homeModules.stylix
          ./modules/home

          (import
            ./users/gaspard.nix
            {
              inherit pkgs;
              enableDesktop = true;
            })
        ];
      };
    };

    deploy.nodes = {
      OVHCloud = {
        hostname = "gasdev.fr";
        profiles.system = {
          user = "root";
          sshUser = "root";
          sshOpts = ["-p" "22"];
          sudo = "";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.OVHCloud;
        };
      };
      pi4 = {
        hostname = "10.8.0.31";
        profiles.system = {
          user = "root";
          sshUser = "root";
          sshOpts = ["-p" "22" "-J" "root@gasdev.fr"];
          sudo = "";
          path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.pi4;
        };
      };
    };

    images.pi4 =
      (self.nixosConfigurations.pi4.extendModules {
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          {
            disabledModules = ["profiles/base.nix"];
          }
        ];
      })
      .config
      .system
      .build
      .sdImage;
    packages.x86_64-linux.pi4-image = images.pi4;
    packages.aarch64-linux.pi4-image = images.pi4;

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        alejandra
        git
        nil
        pkgs.sops
        home-manager.packages."${system}".home-manager
        pkgs.deploy-rs
      ];
    };
  };
}
