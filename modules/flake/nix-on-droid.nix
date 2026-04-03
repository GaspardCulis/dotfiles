{config, inputs, ...}: let
  inherit (inputs) self;

  flake = {inherit self inputs config;};
  
  nixpkgs = inputs.nixpkgs-stable;
  nix-on-droid = inputs.nix-on-droid;

  
in {

  flake = {
    nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
      pkgs = import nixpkgs { 
        stdenv.hostPlatform.system = "aarch64-linux";
        
        overlays = [
          nix-on-droid.overlays.default
        ];
      };
      
      extraSpecialArgs = {inherit flake;};
            
      modules = [ 
        ../../configurations/nix-on-droid/default
      ];

      home-manager-path = inputs.home-manager.outPath;
    };
  };
}
