{
  flake,
  pkgs,
  ...
}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    ./default.nix
    self.homeModules.desktop
  ];

  gasdev = {
    desktop = {
      enable = true;
      niri = {
        enable = true;
        autoStart = true;
        xwayland.enable = true;
      };
      apps = {
        discord.enable = true;
        firefox = {
          progressiveWebApps.enable = true;
          profiles.gaspard.enable = true;
        };
        software-center.enable = true;
      };
      udiskr.enable = true;
    };
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

  xdg.mimeApps = {
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
