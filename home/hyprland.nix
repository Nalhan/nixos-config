# home/hyprland.nix
# declarative config for hyprland WM
# include this file to enable it
{
  
  programs.kitty.enable = true;
  programs.fuzzel.enable = true;
  programs.firefox.enable = true;


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

          "CTRL SHIFT, 4, exec, grimblast copy area"

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
