{
  home.username = "culisg";
  home.homeDirectory = "/home/c/culisg";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  imports = [
    ../../shell
    ../../editor
    ../../de
  ];
}
