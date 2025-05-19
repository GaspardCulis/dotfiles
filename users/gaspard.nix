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
      apps = {
        firefox = {
          progressiveWebApps.enable = true;
          profiles.gaspard.enable = true;
        };
      };
    };
  };

  stylix = {
    enable = true;
    image = ../assets/wallpaper.png;
  };

  services = {
    ssh-agent.enable = true;
  };

  home.file.".ssh/authorized_keys".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQyRXFQ6iA5p0vDuoGSHZfajiVZPAGIyqhTziM7QgBV gaspard@nixos
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICm9trfkWL5FVHuo/5YONd+oZY4nQnpHLDOnXoOrl9j9 u0_a220@pixel
  '';

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
