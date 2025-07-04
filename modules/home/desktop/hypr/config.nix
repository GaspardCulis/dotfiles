{config}: let
  swayosd-client = "${config.gasdev.desktop.swayosd.package}/bin/swayosd-client";
  uwu-launcher = ../../../../bin/hypr/uwu-launcher;
  swaylock = ../../../../bin/hypr/swaylock-hyprland;

  gamemode = ../../../../bin/hypr/gamemode.sh;
  togglescreen = ../../../../bin/hypr/togglescreen;
  power-profile-next = "${../../../../config/eww/scripts/power_profile} next";
  refresh-rate-toggle = "${../../../../config/eww/scripts/refresh_rate} toggle";
in {
  monitor = ",preferred,auto,1";

  exec-once = [
    "nm-applet"
  ];

  env = [
    "GDK_BACKEND, wayland,x11"
    "SDL_VIDEODRIVER, wayland"
    "CLUTTER_BACKEND, wayland"
    "_JAVA_AWT_WM_NONREPARENTING, 1"

    "XDG_CURRENT_DESKTOP, Hyprland"
    "XDG_SESSION_TYPE, wayland"
    "XDG_SESSION_DESKTOP, Hyprland"

    "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
    "QT_QPA_PLATFORM, wayland"
    "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
    "QT_QPA_PLATFORMTHEME, qt6ct"

    "XCURSOR_SIZE, 24"
    "MOZ_ENABLE_WAYLAND, 1"

    "WLR_NO_HARDWARE_CURSORS, 1"
  ];

  "$mainMod" = "SUPER";
  bind =
    [
      "$mainMod, Q, killactive,"
      "$mainMod SHIFT, Q, exit,"
      "$mainMod SHIFT, SPACE, togglefloating,"
      "$mainMod SHIFT, E, pin,"
      "$mainMod, F, fullscreen"

      "$mainMod, RETURN, exec, ${config.gasdev.desktop.apps.terminal}"
      "$mainMod, B, exec, ${config.gasdev.desktop.apps.browser}"
      "$mainMod, N, exec, ${config.gasdev.desktop.apps.explorer}"
      "$mainMod, R, exec, ${config.gasdev.desktop.apps.launcher}"

      "$mainMod, M, exec, prismlauncher"
      "$mainMod, L, exec, ${swaylock}"
      "$mainMod, U, exec, ${uwu-launcher}"

      ",XF86AudioMute, exec, ${swayosd-client} --output-volume mute-toggle"
      ",XF86AudioMicMute, exec, ${swayosd-client} --input-volume mute-toggle"

      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPrev, exec, playerctl previous"

      ",237, exec, brightnessctl -d asus::kbd_backlight set 33%-"
      ",238, exec, brightnessctl -d asus::kbd_backlight set 33%+"

      "$mainMod, F6, exec, grim -g \"$(slurp)\" - | wl-copy"
      "$mainMod, DOLLAR, exec, hyprpicker --autocopy"

      "$mainMod, F5, exec, ${gamemode}"
      "$mainMod, F9, exec, ${togglescreen}"
      ",XF86Launch4, exec, ${power-profile-next}"
      "$mainMod+SHIFT, o, exec, ${refresh-rate-toggle}"

      # Hy3
      "$mainMod, d, hy3:makegroup, h, ephemeral"
      "$mainMod+SHIFT, d, hy3:makegroup, v, ephemeral"
      "$mainMod, z, hy3:makegroup, tab, ephemeral"
      "$mainMod, a, hy3:changefocus, raise"
      "$mainMod+SHIFT, a, hy3:changefocus, lower"
      "$mainMod, s, hy3:changegroup, toggletab"
      "$mainMod, e, hy3:changegroup, opposite"

      "$mainMod, left, hy3:movefocus, l"
      "$mainMod, right, hy3:movefocus, r"
      "$mainMod, up, hy3:movefocus, u"
      "$mainMod, down, hy3:movefocus, d"

      "$mainMod+CONTROL, left, hy3:movefocus, l, visible"
      "$mainMod+CONTROL, down, hy3:movefocus, d, visible"
      "$mainMod+CONTROL, up, hy3:movefocus, u, visible"
      "$mainMod+CONTROL, right, hy3:movefocus, r, visible"

      "$mainMod SHIFT, left, hy3:movewindow, l, once"
      "$mainMod SHIFT, right, hy3:movewindow, r, once"
      "$mainMod SHIFT, up, hy3:movewindow, u, once"
      "$mainMod SHIFT, down, hy3:movewindow, d, once"

      "$mainMod+CONTROL+SHIFT, left, hy3:movewindow, l, once, visible"
      "$mainMod+CONTROL+SHIFT, down, hy3:movewindow, d, once, visible"
      "$mainMod+CONTROL+SHIFT, up, hy3:movewindow, u, once, visible"
      "$mainMod+CONTROL+SHIFT, right, hy3:movewindow, r, once, visible"

      "$mainMod, mouse_down, workspace, e+1"
      "$mainMod, mouse_up, workspace, e-1"
    ]
    ++ (
      # workspaces
      # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
      builtins.concatLists (builtins.genList (
          i: let
            ws = i + 1;
          in [
            "$mainMod, code:1${toString i}, workspace, ${toString ws}"
            "$mainMod SHIFT, code:1${toString i}, movetoworkspacesilent, ${toString ws}"
            "$mainMod+CONTROL, code:1${toString i}, hy3:focustab, index, ${toString ws}"
          ]
        )
        9)
    );

  binde = [
    ",XF86AudioLowerVolume, exec, ${swayosd-client} --output-volume lower"
    ",XF86AudioRaiseVolume, exec, ${swayosd-client} --output-volume raise"
    ",XF86MonBrightnessDown, exec, ${swayosd-client} --brightness lower"
    ",XF86MonBrightnessUp, exec, ${swayosd-client} --brightness raise"

    "$mainMod+ALT, right, resizeactive, 30 0"
    "$mainMod+ALT, left, resizeactive, -30 0"
    "$mainMod+ALT, up, resizeactive, 0 -30"
    "$mainMod+ALT, down, resizeactive, 0 30"
  ];

  bindm = [
    "$mainMod, mouse:272, movewindow"
    "$mainMod, mouse:273, resizewindow"
  ];

  bindn = [
    ", mouse:272, hy3:focustab, mouse"
    ", mouse_down, hy3:focustab, l, require_hovered"
    ", mouse_up, hy3:focustab, r, require_hovered"
  ];

  windowrulev2 = [
    "workspace 9 silent, class:(WebCord)"
    "workspace 9 silent, class:(Element)"

    "float, class:(localsend_app)"
    "float, class:(nm-connection-editor)"
    "float, class:(.blueman-manager-wrapped)"
    "float, class:(localsend_app)"
    "float, class:(PrismLauncher)"
    # UwU
    "float, class:(uwu-uwu)"
    "size 470 650, class:(uwu-uwu)"
    "move 70% 15%, class:(uwu-uwu)"
    "float, class:(uwu-neofetch)"
    "size 820 490, class:(uwu-neofetch)"
    "move 10% 10%, class:(uwu-neofetch)"
    "float, class:(uwu-btm)"
    "size 1024 640, class:(uwu-btm)"
    "move 25% 50%, class:(uwu-btm)"
  ];

  animations = {
    enabled = true;

    bezier = [
      "myBezier, 0.05, 0.9, 0.1, 1.05"
    ];

    animation = [
      "windows, 1, 7, myBezier"
      "windowsOut, 1, 7, default, popin 80%"
      "border, 1, 10, default"
      "borderangle, 1, 8, default"
      "fade, 1, 7, default"
      "workspaces, 1, 6, default"
    ];
  };

  decoration = {
    rounding = 10;

    blur = {
      enabled = true;
      size = 3;
      passes = 1;
    };

    shadow = {
      enabled = true;
      range = 4;
      render_power = 4;
      color = "rgba(1a1a1aee)";
    };
  };

  dwindle = {
    pseudotile = true;
    preserve_split = true;
  };

  ecosystem = {
    no_update_news = true;
    # Yes I'm a cruel being
    no_donation_nag = true;
  };

  input = {
    kb_layout = "fr";

    follow_mouse = 1;

    touchpad = {
      natural_scroll = true;
    };

    sensitivity = 0;
  };

  general = {
    gaps_in = 5;
    gaps_out = "16, 8, 8, 8";
    border_size = 2;
    "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
    "col.inactive_border" = "rgba(595959aa)";

    layout = "hy3";
  };

  gestures = {
    workspace_swipe = true;
  };

  misc = {
    enable_anr_dialog = false;
    disable_hyprland_logo = true;
    disable_splash_rendering = true;
    force_default_wallpaper = 0;
  };

  plugin = {
    hy3 = {
      tabs.text_font = config.gasdev.desktop.theme.font.name;
      autotile.enable = true;
    };
  };

  xwayland = {
    force_zero_scaling = true;
  };
}
