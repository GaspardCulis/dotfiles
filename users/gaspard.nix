{...}: {
  home.username = "gaspard";
  home.homeDirectory = "/home/gaspard";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
  programs.direnv.enable = true;

  imports = [
    ../shell
    ../term
    ../editor
    ../de
    ../gaming
    ../themes/pomme.nix
  ];
}
