{
  config,
  pkgs,
}:
with config.lib.niri.actions; let
  apps = config.gasdev.desktop.apps;
  cfg = config.gasdev.desktop.niri;

  left = "H";
  down = "J";
  up = "K";
  right = "L";

  sh = spawn "sh" "-c";

  ashellEnabled = config.gasdev.desktop.ashell.enable;
  ashell = pkgs.lib.getExe config.gasdev.desktop.ashell.package;

  noctacliaEnabled = config.gasdev.desktop.noctalia.enable;
  noctalia = "noctalia";

  playerctl = pkgs.lib.getExe pkgs.playerctl;
in {
  prefer-no-csd = true;

  binds =
    {
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
        action.spawn = apps.launcherCmd;
        repeat = false;
      };

      "Mod+F6".action.screenshot = {
        show-pointer = true;
      };
      "Mod+DOLLAR".action = sh "niri msg pick-color | grep -oP 'Hex: \\K#\\w+' | tr -d '\\n' | wl-copy";

      "Mod+S".action = switch-preset-column-width;
      "Mod+Shift+S".action = switch-preset-column-width-back;
      "Mod+F".action = maximize-column;
      "Mod+Shift+F".action = fullscreen-window;
      "Mod+Shift+Space".action = toggle-window-floating;

      "Mod+E".action = toggle-column-tabbed-display;

      "Mod+M".action = focus-monitor-next;
      "Mod+Shift+M".action = move-column-to-monitor-next;
      "Mod+Ctrl+Shift+M".action = move-workspace-to-monitor-next;

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

      "Mod+Shift+ampersand".action.move-column-to-workspace = 1;
      "Mod+Shift+eacute".action.move-column-to-workspace = 2;
      "Mod+Shift+quotedbl".action.move-column-to-workspace = 3;
      "Mod+Shift+apostrophe".action.move-column-to-workspace = 4;
      "Mod+Shift+parenleft".action.move-column-to-workspace = 5;
      "Mod+Shift+minus".action.move-column-to-workspace = 6;
      "Mod+Shift+egrave".action.move-column-to-workspace = 7;
      "Mod+Shift+underscore".action.move-column-to-workspace = 8;
      "Mod+Shift+ccedilla".action.move-column-to-workspace = 9;
      "Mod+Shift+agrave".action.move-column-to-workspace = 10;

      "Mod+O".action = toggle-overview;
      "Mod+Shift+comma".action = show-hotkey-overlay;

      "XF86AudioPlay".action = spawn playerctl "play";
      "XF86AudioPause".action = spawn playerctl "pause";
      "XF86AudioNext".action = spawn playerctl "next";
      "XF86AudioPrev".action = spawn playerctl "previous";
    }
    // pkgs.lib.optionalAttrs ashellEnabled {
      "XF86AudioMute".action = spawn ashell "msg" "volume-toggle-mute";
      "XF86AudioMicMute".action = spawn ashell "msg" "microphone-toggle-mute";
      "XF86AudioLowerVolume".action = spawn ashell "msg" "volume-down";
      "XF86AudioRaiseVolume".action = spawn ashell "msg" "volume-up";
      "XF86MonBrightnessDown".action = spawn ashell "msg" "brightness-down";
      "XF86MonBrightnessUp".action = spawn ashell "msg" "brightness-up";
    }
    // pkgs.lib.optionalAttrs noctacliaEnabled {
      "XF86AudioMute".action = spawn noctalia "msg" "volume-mute";
      "XF86AudioMicMute".action = spawn noctalia "msg" "mic-mute";
      "XF86AudioLowerVolume".action = spawn noctalia "msg" "volume-down";
      "XF86AudioRaiseVolume".action = spawn noctalia "msg" "volume-up";
      "XF86MonBrightnessDown".action = spawn noctalia "msg" "brightness-down";
      "XF86MonBrightnessUp".action = spawn noctalia "msg" "brightness-up";
    };

  environment = {
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";

    MOZ_ENABLE_WAYLAND = "1";

    DISPLAY = pkgs.lib.mkIf cfg.xwayland.enable ":0";
  };

  gestures = {
    hot-corners.enable = false;
  };

  input = {
    keyboard.xkb.layout = "fr";
    warp-mouse-to-focus.enable = true;

    power-key-handling.enable = false;
  };

  layout = {
    default-column-width = {
      proportion = 9. / 10.;
    };
    preset-column-widths = [
      {proportion = 1. / 3.;}
      {proportion = 1. / 2.;}
      {proportion = 2. / 3.;}
      {proportion = 9. / 10.;}
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
    pkgs.lib.lists.optionals cfg.xwayland.enable
    [{command = ["${pkgs.lib.getExe pkgs.xwayland-satellite}"];}]
    ++ pkgs.lib.lists.optionals noctacliaEnabled
    [{command = ["noctalia"];}];

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
        {app-id = "vesktop";}
      ];
      open-on-workspace = "9";
      block-out-from = "screencast";
      open-focused = false;
    }
    {
      # Games in fullscreen
      matches = [
        {title = "Mindustry";}
        {app-id = "Vintage Story";}
        {app-id = "Terraria.bin.x86_64";}
      ];
      open-fullscreen = true;
    }
    (pkgs.lib.optionalAttrs noctacliaEnabled {
      matches = [{app-id = "dev.noctalia.Noctalia";}];
      open-floating = true;
      default-column-width = {fixed = 1080;};
      default-window-height = {fixed = 920;};
    })
  ];

  workspaces = {
    "1" = {};
    "2" = {};
    "3" = {};
    "4" = {};
    "5" = {};
    "6" = {};
    "7" = {};
    "8" = {};
    "9" = {open-on-output = "eDP-1";}; # Keep waifu gifs on primary monitor
  };

  hotkey-overlay.skip-at-startup = true;

  layer-rules = [
    (pkgs.lib.optionalAttrs noctacliaEnabled {
      matches = [{namespace = "^noctalia-backdrop";}];
      place-within-backdrop = true;
    })
  ];

  debug = pkgs.lib.mkIf noctacliaEnabled {
    honor-xdg-activation-with-invalid-serial = {};
  };
}
