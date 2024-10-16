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
    ".local/bin/Hyprland-wrapper" = {
      source = ../../bin/Hyprland-wrapper;
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
    # Lock script
    ".local/bin/swaylock-hyprland" = {
      source = ../../bin/swaylock-hyprland;
      executable = true;
    };
  };

  home.packages = with pkgs; [
    egl-wayland # For NVIDIA compatibility
    xdg-desktop-portal-hyprland
    # Common DE packages required in config
    wl-clipboard
    grim
    slurp
    hyprpicker
    udiskie
    swww
    swaylock-effects
    brightnessctl
    networkmanagerapplet
    # Apps launchable from bindings
    firefox
    kitty
    yazi
    # Yazi requirements
    ffmpegthumbnailer
    poppler
    imagemagick
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
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
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
