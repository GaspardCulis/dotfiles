{pkgs, ...}: {
  home.file = {
    ".config/swayosd/style.css".source = ./style.css;
  };

  home.packages = [
    pkgs.swayosd
  ];
}
