{pkgs, ...}: {
  home.file = {
    ".config/zellij/config.kdl".source = ./config.kdl;
  };

  home.packages = [
    pkgs.zellij
  ];
}
