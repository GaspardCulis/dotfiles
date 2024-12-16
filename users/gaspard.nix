{...}: {
  imports = [
    ../shell
    ../term
    ../editor
    ../de
    ../gaming
    ../themes/pomme.nix
  ];

  home.username = "gaspard";
  home.homeDirectory = "/home/gaspard";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
  programs.direnv.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };
}
