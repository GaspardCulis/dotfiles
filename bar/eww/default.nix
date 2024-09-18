{
  pkgs,
  ...
} : {
  home.file = {
    ".config/eww".source = ../eww;
  };
  
  home.packages = [
    pkgs.eww
  ];
}



