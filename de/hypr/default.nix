{
  inputs,
  pkgs,
  ...
}: {
  home.file = {
    ".config/hypr/hyprland.conf.d".source = ./hyprland.conf.d;
    # Gamemode script
    ".config/hypr/gamemode.sh" = {
      source = ./gamemode.sh;
      executable = true;
    };
    # Hyprland launch wrapper
    ".local/bin/Hyprland" = {
      source = ../../bin/Hyprland;
      executable = true;
    };
    # UWU launcher script
    ".local/bin/uwu-launcher" = {
      source = ../../bin/uwu-launcher;
      executable = true;
    };
    # Togglescreen script
    ".local/bin/togglescreen" = {
      source = ../../bin/togglescreen;
      executable = true;
    };
    # Wallpaperctl script
    ".local/bin/wallpaperctl" = {
      source = ../../bin/wallpaperctl;
      executable = true;
    };
  };

  home.packages = [
    pkgs.egl-wayland # For NVIDIA compatibility
    pkgs.xdg-desktop-portal-hyprland
    # Common DE packages required in config
    pkgs.wl-clipboard
    pkgs.grim
    pkgs.slurp
    pkgs.hyprpicker
    pkgs.udiskie
    pkgs.swww
    # Apps launchable from bindings
    pkgs.firefox
    pkgs.kitty
    pkgs.yazi
  ];

  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./hyprland.conf;
    plugins = [inputs.hy3.packages.${pkgs.system}.hy3];
  };

  # bar is required
  imports = [
    ../../bar
    ../../term/alacritty
    ../../misc/swayosd
    ../../misc/anyrun
    ../../misc/end-rs
  ];
}
