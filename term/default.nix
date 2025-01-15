{pkgs, ...}: {
  imports = [
    ./alacritty
    ./zellij
  ];

  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji

    nerd-fonts.fira-code
    fira-code-symbols
  ];

  fonts.fontconfig.enable = true;
}
