{
  description = "Configuration Home Manager jaajesque";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/make-disk-image";
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
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    home-manager,
    hy3,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations = {
      Zephyrus = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/Zephyrus
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
        ];
      };
    };

    homeConfigurations = {
      "gaspard" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {inherit hy3;};
        modules = [
          ./users/gaspard.nix
        ];
      };

      "culisg@im2ag" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {inherit hy3;};
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
