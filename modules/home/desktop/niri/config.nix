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
  input = {
    keyboard.xkb.layout = "fr";
    warp-mouse-to-focus.enable = true;
  };

  binds = with config.lib.niri.actions; {
    "Mod+Q".action = close-window;
    "Mod+F".action = toggle-windowed-fullscreen;

    "Mod+Return" = {
      action.spawn = "${apps.terminal}";
      repeat = false;
    };
    "Mod+B" = {
      action.spawn = "${apps.browser}";
      repeat = false;
    };
    "Mod+N" = {
      action.spawn = "${apps.explorer}";
      repeat = false;
    };
    "Mod+R" = {
      action.spawn = "${apps.launcher}";
      repeat = false;
    };

    "XF86AudioMute".action = spawn "${swayosd-client} --output-volume mute-toggle";
    "XF86AudioMicMute".action = spawn "${swayosd-client} --input-volume mute-toggle";
    "XF86AudioLowerVolume".action = spawn "${swayosd-client} --output-volume lower";
    "XF86AudioRaiseVolume".action = spawn "${swayosd-client} --output-volume raise";
    "XF86MonBrightnessDown".action = spawn "${swayosd-client} --brightness lower";
    "XF86MonBrightnessUp".action = spawn "${swayosd-client} --brightness raise";

    "Mod+H".action = focus-column-left;
    "Mod+J".action = focus-window-down;
    "Mod+K".action = focus-window-up;
    "Mod+L".action = focus-column-right;

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
  };
}
