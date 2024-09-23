{
  description = "Configuration Home Manager jaajesque";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      follows = "hy3/hyprland";
    };
    hy3 = {
      url = "github:outfoxxed/hy3";
    };

    end-rs = {
      url = "github:Dr-42/end-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations = {
      Zephyrus = nixpkgs.lib.nixosSystem {
        extraArgs = {inherit inputs;};
        modules = [
          ./hosts/Zephyrus
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
        ];
      };

      OVHCloud = nixpkgs.lib.nixosSystem {
        extraArgs = {inherit inputs;};
        modules = [
          ./hosts/OVHCloud
          disko.nixosModules.disko
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

    devShells.${system}.default = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        git
        helix
        pkgs.home-manager
        alejandra
        nil
      ];

      shellHook = ''
        export EDITOR=hx
      '';
    };
  };
}
