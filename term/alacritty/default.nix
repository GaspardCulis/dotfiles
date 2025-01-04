{pkgs, ...}: {
  home.file = {
    ".config/alacritty/alacritty.toml".source = ./alacritty.toml;
  };

  home.packages = with pkgs; [
    alacritty
  ];
}
