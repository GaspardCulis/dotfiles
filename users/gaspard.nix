{...}: {
  home.username = "gaspard";
  home.homeDirectory = "/home/gaspard";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
  programs.direnv.enable = true;

  gasdev = {
    shell = {
      bash.enable = true;
      helix.enable = true;
      zellij.enable = true;
    };
    desktop = {
      enable = true;
      hypr = {
        enable = true;
        autoStart = true;
      };
    };
  };

  services = {
    ssh-agent.enable = true;
  };

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
