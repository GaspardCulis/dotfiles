{
  description = "Configuration Home Manager jaajesque";

  inputs = {
    # Common
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    nixos-unified.url = "github:srid/nixos-unified";
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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

    jaaj-rs.url = "git+https://git.ahur.ac/Jaaj-San/jaaj-rs";

    wakatime-ls = {
      url = "github:mrnossiom/wakatime-ls";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    udiskr = {
      url = "github:d-itu/udiskr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SteamOS
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    suyu = {
      url = "github:Noodlez1232/suyu-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Wired using https://nixos-unified.org/guide/autowiring
  outputs = inputs:
    inputs.nixos-unified.lib.mkFlake {
      inherit inputs;
      root = ./.;
    };
}
