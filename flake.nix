{
  description = "Configuration Home Manager jaajesque";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caddy = {
      url = "github:GaspardCulis/nixos-caddy-ovh";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland
    hyprland = {
      url = "github:hyprwm/Hyprland?submodules=1&ref=v0.48.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hy3 = {
      url = "github:outfoxxed/hy3?ref=hl0.48.0";
      inputs.hyprland.follows = "hyprland";
    };

    end-rs = {
      url = "github:Dr-42/end-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    anyrun = {
      url = "github:anyrun-org/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    anixrun = {
      url = "github:GaspardCulis/anixrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jaaj-rs = {
      url = "git+https://git.ahur.ac/Jaaj-San/jaaj-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SteamOS
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    deploy-rs,
    sops-nix,
    home-manager,
    jovian,
    nixos-hardware,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in rec {
    nixosConfigurations = {
      Zephyrus = nixpkgs.lib.nixosSystem {
        extraArgs = {inherit inputs;};
        modules = [
          ./hosts/Zephyrus
          disko.nixosModules.disko
          nixos-hardware.nixosModules.asus-zephyrus-ga503
          home-manager.nixosModules.home-manager
          jovian.nixosModules.jovian
        ];
      };

      OVHCloud = nixpkgs.lib.nixosSystem {
        extraArgs = {inherit inputs;};
        modules = [
          ./hosts/OVHCloud
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
        ];
      };

      pi4 = nixpkgs.lib.nixosSystem {
        extraArgs = {inherit inputs;};
        system = "aarch64-linux";
        modules = [
          ./hosts/pi4
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
          ./users/gaspard.nix
        ];
      };

      "culisg@im2ag" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./users/culisg.nix
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
        helix
        nil
        pkgs.sops
        pkgs.home-manager
        pkgs.deploy-rs
      ];

      shellHook = ''
        export EDITOR=hx
      '';
    };
  };
}
