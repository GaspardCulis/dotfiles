{
  description = "Configuration Home Manager jaajesque";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
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

  outputs = { self, nixpkgs, home-manager, hy3, ... }: 
    let 
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
  {
    homeConfigurations."culisg@im2ag" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      extraSpecialArgs = {inherit hy3;};
      modules = [
        ./nix/profiles/culisg.nix
      ];
    };
  };
}
