{
  config,
  pkgs,
  ...
} : {
  home.file = {
    ".config/alacritty/alacritty.toml".source = ./alacritty.toml;
  };
  
  home.packages = [
    pkgs.alacritty
    pkgs.fira-code-nerdfont
  ];

  fonts.fontconfig.enable = true;
}


