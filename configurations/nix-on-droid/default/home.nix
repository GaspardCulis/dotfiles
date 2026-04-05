{flake, ...}: let
  inherit (flake.inputs) self;
in {
  imports = [
    (self + /configurations/home/gaspard)
  ];

  # Stylix not present
  programs.helix.settings.theme = "sonokai";

  # Read the changelog before changing this value
  home.stateVersion = "24.05";
}
