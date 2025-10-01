{
  config,
  pkgs,
}: let
  apps = config.gasdev.desktop.apps;
  cfg = config.gasdev.desktop.niri;

  swayosd-client = "${config.gasdev.desktop.swayosd.package}/bin/swayosd-client";
  uwu-launcher = ../../../../bin/hypr/uwu-launcher;
  swaylock = ../../../../bin/hypr/swaylock-hyprland;

  gamemode = ../../../../bin/hypr/gamemode.sh;
  togglescreen = ../../../../bin/hypr/togglescreen;
  power-profile-next = "${../../../../config/eww/scripts/power_profile} next";
  refresh-rate-toggle = "${../../../../config/eww/scripts/refresh_rate} toggle";
in {
  prefer-no-csd = true;

  binds = with config.lib.niri.actions; let
    left = "H";
    down = "J";
    up = "K";
    right = "L";

    sh = spawn "sh" "-c";
  in {
    "Mod+Q".action = close-window;
    "Mod+Shift+Q".action = quit;

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

    "Mod+F6".action = screenshot {
      show-pointer = true;
    };
    "Mod+DOLLAR".action = sh "niri msg pick-color | grep -oP 'Hex: \\K#\\w+' | tr -d '\\n' | wl-copy";

    "XF86AudioMute".action = spawn swayosd-client "--output-volume" "mute-toggle";
    "XF86AudioMicMute".action = spawn swayosd-client "--input-volume" "mute-toggle";
    "XF86AudioLowerVolume".action = spawn swayosd-client "--output-volume" "lower";
    "XF86AudioRaiseVolume".action = spawn swayosd-client "--output-volume" "raise";
    "XF86MonBrightnessDown".action = spawn swayosd-client "--brightness" "lower";
    "XF86MonBrightnessUp".action = spawn swayosd-client "--brightness" "raise";

    "Mod+S".action = switch-preset-column-width;
    "Mod+Shift+S".action = switch-preset-column-width-back;
    "Mod+F".action = maximize-column;
    "Mod+Shift+F".action = fullscreen-window;
    "Mod+Shift+Space".action = toggle-window-floating;

    "Mod+M".action = move-column-to-monitor-next;
    "Mod+Shift+M".action = move-workspace-to-monitor-next;

    "Mod+${left}".action = focus-column-left;
    "Mod+${down}".action = focus-window-or-workspace-down;
    "Mod+${up}".action = focus-window-or-workspace-up;
    "Mod+${right}".action = focus-column-right;

    "Mod+Shift+${left}".action = consume-or-expel-window-left;
    "Mod+Shift+${down}".action = move-window-down-or-to-workspace-down;
    "Mod+Shift+${up}".action = move-window-up-or-to-workspace-up;
    "Mod+Shift+${right}".action = consume-or-expel-window-right;

    "Mod+WheelScrollUp".action = focus-column-right;
    "Mod+WheelScrollDown".action = focus-column-left;
    "Mod+Shift+WheelScrollUp".action = move-column-right;
    "Mod+Shift+WheelScrollDown".action = move-column-left;

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

    "Mod+O".action = toggle-overview;
    "Mod+Shift+comma".action = show-hotkey-overlay;
  };

  environment = {
    DISPLAY = pkgs.lib.mkIf cfg.xwayland.enable ":0";
  };

  gestures = {
    hot-corners.enable = false;
  };

  input = {
    keyboard.xkb.layout = "fr";
    warp-mouse-to-focus.enable = true;
  };

  layout = {
    default-column-width = {
      proportion = 2. / 3.;
    };
    preset-column-widths = [
      {proportion = 1. / 3.;}
      {proportion = 1. / 2.;}
      {proportion = 2. / 3.;}
    ];
  };

  outputs = {
    "eDP-1" = {
      scale = 1.2;
      variable-refresh-rate = "on-demand";
    };
    "HDMI-A-1" = {
      scale = 1;
    };
  };

  spawn-at-startup =
    if cfg.xwayland.enable
    then [
      {
        command = ["${pkgs.lib.getExe pkgs.xwayland-satellite}"];
      }
    ]
    else [];

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
      # Chat
      matches = [
        {app-id = "WebCord";}
        {app-id = "Element";}
      ];
      open-on-workspace = "chat";
      block-out-from = "screencast";
      open-focused = false;
    }
    {
      # Games in fullscreen
      matches = [
        {title = "Mindustry";}
        {app-id = "Vintage Story";}
      ];
      open-fullscreen = true;
    }
  ];

  workspaces."chat" = {
    open-on-output = "eDP-1"; # Keep waifu gifs on primary monitor
  };

  hotkey-overlay.skip-at-startup = true;
}
