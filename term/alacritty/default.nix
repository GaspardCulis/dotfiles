{pkgs, ...}: {
  home.file = {
    ".config/alacritty/alacritty.toml".source = ./alacritty.toml;
  };

  home.packages = with pkgs; [
    alacritty
    fira-code-nerdfont
    fira-code-symbols
  ];

  fonts.fontconfig.enable = true;
}
