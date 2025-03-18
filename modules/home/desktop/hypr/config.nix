{config}: {
  monitor = ",preferred,auto,1";

  env = [
    "GDK_BACKEND, wayland,x11"
    "SDL_VIDEODRIVER, wayland"
    "CLUTTER_BACKEND, wayland"
    "_JAVA_AWT_WM_NONREPARENTING, 1"

    "XDG_CURRENT_DESKTOP, Hyprland"
    "XDG_SESSION_TYPE, wayland"
    "XDG_SESSION_DESKTOP, Hyprland"

    "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
    "QT_QPA_PLATFORM, 1"
    "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
    "QT_QPA_PLATFORMTHEME, qt6ct"

    "XCURSOR_SIZE, 2"
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
      "$mainMod, L, exec, swaylock-hyprland"
      "$mainMod, U, exec, ${../../../../bin/uwu-launcher}"

      ",XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
      ",XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"

      ",237, exec, brightnessctl -d asus::kbd_backlight set 33%-"
      ",238, exec, brightnessctl -d asus::kbd_backlight set 33%+"
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
    ",XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
    ",XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
    ",XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
    ",XF86MonBrightnessUp, exec, swayosd-client --brightness raise"

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

  animations = {
    enabled = true;
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

  plugin = {
    hy3 = {
      tabs.text_font = config.gasdev.desktop.theme.font.name;
    };
  };

  xwayland = {
    force_zero_scaling = true;
  };
}
