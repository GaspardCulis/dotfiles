{flake, ...}: let
  inherit (flake.inputs) self;
in {
  imports = [
    (self + /configurations/home/gaspard)
  ];

  # Read the changelog before changing this value
  home.stateVersion = "24.05";
}
