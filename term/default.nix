{pkgs, ...}: {
  imports = [
    ./alacritty
    ./zellij
  ];

  home.packages = with pkgs; [
    fira-code-nerdfont
    fira-code-symbols
  ];

  fonts.fontconfig.enable = true;
}
