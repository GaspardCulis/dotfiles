{config}: let
  apps = config.gasdev.desktop.apps;

  swayosd-client = "${config.gasdev.desktop.swayosd.package}/bin/swayosd-client";
  uwu-launcher = ../../../../bin/hypr/uwu-launcher;
  swaylock = ../../../../bin/hypr/swaylock-hyprland;

  gamemode = ../../../../bin/hypr/gamemode.sh;
  togglescreen = ../../../../bin/hypr/togglescreen;
  power-profile-next = "${../../../../config/eww/scripts/power_profile} next";
  refresh-rate-toggle = "${../../../../config/eww/scripts/refresh_rate} toggle";
in {
  prefer-no-csd = true;

  binds = with config.lib.niri.actions; {
    "Mod+Q".action = close-window;
    "Mod+F".action = fullscreen-window;

    "Mod+Return" = {
      hotkey-overlay.title = "Spawn terminal emulator";
      action.spawn = "${apps.terminal}";
      repeat = false;
    };
    "Mod+B" = {
      hotkey-overlay.title = "Spawn Web browser";
      action.spawn = "${apps.browser}";
      repeat = false;
    };
    "Mod+N" = {
      hotkey-overlay.title = "Spawn file explorer";
      action.spawn = "${apps.explorer}";
      repeat = false;
    };
    "Mod+R" = {
      hotkey-overlay.title = "Spawn quick launcher";
      action.spawn = "${apps.launcher}";
      repeat = false;
    };

    "XF86AudioMute".action = spawn "${swayosd-client} --output-volume mute-toggle";
    "XF86AudioMicMute".action = spawn "${swayosd-client} --input-volume mute-toggle";
    "XF86AudioLowerVolume".action = spawn "${swayosd-client} --output-volume lower";
    "XF86AudioRaiseVolume".action = spawn "${swayosd-client} --output-volume raise";
    "XF86MonBrightnessDown".action = spawn "${swayosd-client} --brightness lower";
    "XF86MonBrightnessUp".action = spawn "${swayosd-client} --brightness raise";

    "Mod+S".action = switch-preset-column-width;

    "Mod+H".action = focus-column-left;
    "Mod+J".action = focus-window-down;
    "Mod+K".action = focus-window-up;
    "Mod+L".action = focus-column-right;

    "Mod+Shift+H".action = move-column-left;
    "Mod+Shift+J".action = move-window-down;
    "Mod+Shift+K".action = move-window-up;
    "Mod+Shift+L".action = move-column-right;

    "Mod+ampersand".action.focus-workspace = 1;
    "Mod+eacute".action.focus-workspace = 2;
    "Mod+quotedbl".action.focus-workspace = 3;
    "Mod+apostrophe".action.focus-workspace = 4;
    "Mod+parenleft".action.focus-workspace = 5;
    "Mod+minus".action.focus-workspace = 6;
    "Mod+egrave".action.focus-workspace = 7;
    "Mod+underscore".action.focus-workspace = 8;
    "Mod+ccedilla".action.focus-workspace = 9;
    "Mod+agrave".action.focus-workspace = 10;

    "Mod+Shift+comma".action = show-hotkey-overlay;
  };

  input = {
    keyboard.xkb.layout = "fr";
    warp-mouse-to-focus.enable = true;
  };

  layout = {
    preset-column-widths = [
      {proportion = 1. / 3.;}
      {proportion = 1. / 2.;}
      {proportion = 2. / 3.;}
    ];
  };

  switch-events = {
    lid-close = {
      action.spawn = {}; # TODO: Lock
    };
  };

  window-rules = [
    {
      # Default
      geometry-corner-radius = {
        top-left = 12.0;
        top-right = 12.0;
        bottom-left = 12.0;
        bottom-right = 12.0;
      };
      clip-to-geometry = true;
    }
    {
      # Browser
      matches = [
        {
          app-id = "firefox";
        }
      ];
      open-maximized = true;
    }
  ];

  environment = {
    GDK_BACKEND = "wayland,x11";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";

    XDG_CURRENT_DESKTOP = "Niri";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Niri";

    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_QPA_PLATFORMTHEME = "qt6ct";

    XCURSOR_SIZE = "24";
    MOZ_ENABLE_WAYLAND = "1";
  };

  hotkey-overlay.skip-at-startup = true;
}
