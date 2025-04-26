# home/hyprland.nix
# declarative config for hyprland WM
# include this file to enable it
{
  
  programs.kitty.enable = true;
  programs.fuzzel.enable = true;
  programs.firefox.enable = true;

  imports = 
  [
    ../home/swaync/swaync.nix 
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManger" = "dolphin";
      "$menu" = "fuzzel";
      
      # monitor = [
        # ", preferred, auto, auto"
        # "DP-1, 1920x1200, 0x0, 1, transform, 1"
      # ];

      general = {
        gaps_in = 3;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 8;
        rounding_power = 2;

        active_opacity = 1.0;
        inactive_opacity = 1.0;
        
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };

        blur = {
          enabled = true;
          size = 3;
          passes = 1;

          vibrancy = 0.1696;
        };

      };

      animations = {
        enabled = "yes, please :)";
        
        bezier = 
          [
            "easeOutQuint,0.23,1,0.32,1"
            "easeInOutCubic,0.65,0.05,0.36,1"
            "linear,0,0,1,1"
            "almostLinear,0.5,0.5,0.75,1.0"
            "quick,0.15,0,0.1,1"
          ];
        
        animation = 
          [
            "global, 1, 10, default"
            "border, 1, 5.39, easeOutQuint"
            "windows, 1, 4.79, easeOutQuint"
            "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
            "windowsOut, 1, 1.49, linear, popin 87%"
            "fadeIn, 1, 1.73, almostLinear"
            "fadeOut, 1, 1.46, almostLinear"
            "fade, 1, 3.03, quick"
            "layers, 1, 3.81, easeOutQuint"
            "layersIn, 1, 4, easeOutQuint, fade"
            "layersOut, 1, 1.5, linear, fade"
            "fadeLayersIn, 1, 1.79, almostLinear"
            "fadeLayersOut, 1, 1.39, almostLinear"
            "workspaces, 1, 1.94, almostLinear, fade"
            "workspacesIn, 1, 1.21, almostLinear, fade"
            "workspacesOut, 1, 1.94, almostLinear, fade"
          ];
      };

    

      bind =
        [
          "$mod, Q, exec, $terminal"
          "$mod, SPACE, exec, $menu"
          "$mod, F, exec, firefox"
          "$mod, C, killactive"
          "$mod, M, exit"
          "$mod, V, togglefloating"
          "$mod, J, togglesplit"
          "$mod, P, pseudo"

          "$mod, Print, exec, grimblast copy area"

          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          "$mod, S, togglespecialworkspace, magic"
          "$mod SHIFT, S, movetoworkspace, special:magic"

          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"
        ]
        ++

       (
          # workspaces
          # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
          builtins.concatLists (builtins.genList (i:
              let ws = i + 1;
              in [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            )
            9)
            );

    
      bindm = 
        [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
        
      cursor = {
        no_warps = true;
      };

      input = { 
        sensitivity = -0.1;
        follow_mouse = 0;
        off_window_axis_events = 0;
      };

    };

    extraConfig = "
           monitor = , preferred, auto, auto
           monitor = DP-1, 1920x1200, -1200x0, 1, transform, 1
           monitor = DP-2, 2560x1440@144, 0x0, 1
           monitor = DP-3, 1920x1080, 2560x0, 1
           ";
  };
}

