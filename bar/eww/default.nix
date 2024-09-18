{
  pkgs,
  ...
} : {
  home.file = {
    ".config/eww".source = .;
  };
  
  home.packages = [
    pkgs.eww
  ];
}



