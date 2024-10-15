{pkgs, ...}: {
  home.packages = [pkgs.dconf];
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-light";
    };
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.qogir-theme;
      name = "qogir-dark";
    };
    iconTheme = {
      package = pkgs.qogir-icon-theme;
      name = "Qogir";
    };
  };
}
