{pkgs, ...}: {
  home.packages = with pkgs; [
    gamemode
  ];

  imports = [
    ./minecraft
  ];
}
