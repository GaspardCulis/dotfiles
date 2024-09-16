{
  description = "Configuration Home Manager jaajesque";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: 
    let 
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
  {
    homeConfigurations."culisg@im2ag" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        ./nix/profiles/culisg.nix
      ];
    };
  };
}
