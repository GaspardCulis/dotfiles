{
  inputs,
  pkgs,
  ...
}: {
  home.file = {
    ".config/hypr/hyprland.conf.d".source = ./hyprland.conf.d;
    # Hyprland launch wrapper
    ".local/bin/Hyprland" = {
      source = ../../bin/Hyprland;
      executable = true;
    };
  };

  home.packages = [
    pkgs.egl-wayland # For NVIDIA compatibility
    pkgs.xdg-desktop-portal-hyprland
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./hyprland.conf;
    plugins = [inputs.hy3.packages.${pkgs.system}.hy3];
  };

  # bar is required
  imports = [
    ../../bar
  ];
}
