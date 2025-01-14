{pkgs, ...}: {
  imports = [
    ./alacritty
    ./zellij
  ];

  home.packages = with pkgs; [
    nerd-fonts.fira-code
    fira-code-symbols
  ];

  fonts.fontconfig.enable = true;
}
