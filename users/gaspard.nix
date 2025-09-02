{
  pkgs,
  enableDesktop ? false,
  enableGaming ? false,
  ...
}: let
  lib = pkgs.lib;
in {
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
    desktop = lib.mkIf enableDesktop {
      enable = true;
      niri = {
        enable = true;
        autoStart = true;
        xwayland.enable = true;
      };
      apps = lib.mkIf enableDesktop {
        firefox = {
          progressiveWebApps.enable = true;
          profiles.gaspard.enable = true;
        };
        games.enable = enableGaming;
      };
      udiskr.enable = true;
    };
  };

  services = {
    ssh-agent.enable = true;
  };

  stylix = {
    enable = true;
    icons = {
      enable = true;
      package = pkgs.colloid-icon-theme;
      dark = "Colloid-Dark";
      light = "Colloid-Light";
    };
  };

  xdg.mimeApps = lib.mkIf enableDesktop {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "application/pdf" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };
}
