{pkgs, ...}: {
  home.file = {
    ".config/ghostty/config".source = ./config;
  };

  home.packages = with pkgs; [
    ghostty
  ];
}
