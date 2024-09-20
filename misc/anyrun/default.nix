{pkgs, ...}: {
  home.file = {
    ".config/anyrun".source = ../anyrun;
  };

  home.packages = [
    pkgs.anyrun
  ];
}
