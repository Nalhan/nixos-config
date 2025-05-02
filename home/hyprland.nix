# home/hyprland.nix
# declarative config for hyprland WM
# include this file to enable it
username: { config, lib, pkgs, hyprland, hyprland-plugins, hyprsplit, ...}:

{
  services.xserver = {
    enable = true;
    displayManager.lightdm = {
      greeters.slick.enable = true;
      extraConfig = ''
        display-setup-script=xrandr --output DP-2 --primary
      '';
    };
  };
  
  programs.hyprland = {
    enable = true; 
    xwayland.enable = true;
  };

  services.clipboard-sync.enable = true;



  environment.systemPackages = with pkgs; [
    gnome-network-displays
    hyprcursor
    hyprpolkitagent
  ];

  home-manager.users.${username} = {
    programs.kitty.enable = true;
    programs.fuzzel.enable = true;
    programs.firefox.enable = true;
    
    imports = 
    [
      ../home/swaync/swaync.nix
      ../home/waybar/waybar.nix
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;
      package = hyprland.packages.${pkgs.system}.hyprland;
      plugins = [
        hyprsplit.packages.${pkgs.system}.hyprsplit
      ];
      settings = {
        "$mod" = "SUPER";
        "$terminal" = "kitty";
        "$fileManger" = "dolphin";
        "$menu" = "fuzzel";
        
        # monitor = [
          # ", preferred, auto, auto"
          # "DP-1, 1920x1200, 0x0, 1, transform, 1"
        # ];
        plugin = {
          hyprsplit = {
            num_workspaces = 6;
          };
        };
        
        env = 
        [
          "HYPRCURSOR_THEME,Bibata-Modern-Ice"
          "HYPRCURSOR_SIZE,24"
        ];

        exec-once = 
        [
          "xrandr --output DP-2 --primary"
          "waybar"
          "signal-desktop"
          "vesktop"
          "[workspace 13 silent] firefox"
          "[workspace 9 silent] steam"
          "plexamp"
          "[workspace special:magic silent] 1password"
          "systemctl --user start hyprpolkitagent"
        ];

        general = {
          gaps_in = 6;
          gaps_out = 8;
          border_size = 2;
          #"col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          #"col.inactive_border" = "rgba(595959aa)";

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
            #color = "rgba(1a1a1aee)";
          };

          blur = {
            enabled = true;
            size = 8;
            passes = 2;

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

        windowrule = 
        [
          # kitty
          "opacity 0.8 0.7 class:kitty"

          # vesktop
          "workspace 1, class:vesktop"

          # signal
          "workspace 2, class:Signal"

          
          # Plexamp
          "opacity 0.9 0.9 title:Plexamp"
          "float, title:Plexamp"
          "pin, title:Plexamp"
          "size 1180 550, title:Plexamp"
          "move 10 1360, title:Plexamp"
          "monitor 0, title:Plexamp"

          #steam-proton - send games to monitor 1
            

        ];
        windowrulev2 = 
        [
          "maxsize 1180 550, title:Plexamp"
        ];

        layerrule = 
        [
          "blur, waybar"
          "ignorezero, waybar"
          "ignorealpha 0.5, waybar"
        ];

        

        bind =
          [
            "$mod, Q, exec, $terminal"
            "$mod, SPACE, exec, $menu"
            "$mod, F, fullscreen"
            "$mod, C, killactive"
            "$mod ALT SHIFT, M, exit"
            "$mod, V, togglefloating"
            "$mod, J, togglesplit"
            "$mod, P, pseudo"

            "$mod, Print, exec, grimblast copy area"
            ", Print, exec, grimblast copy output"

            "$mod, left, movefocus, l"
            "$mod, right, movefocus, r"
            "$mod, up, movefocus, u"
            "$mod, down, movefocus, d"

            "$mod, S, togglespecialworkspace, magic"
            "$mod SHIFT, S, movetoworkspace, special:magic"
            "$mod, G, togglespecialworkspace, game"
            "$mod SHIFT, G, movetoworkspace, special:game"

            "$mod, mouse_down, split:workspace, e+1"
            "$mod, mouse_up, split:workspace, e-1"
            
          ]
          ++

         (
            # workspaces
            # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
            builtins.concatLists (builtins.genList (i:
                let ws = i + 1;
                in [
                  "$mod, code:1${toString i}, split:workspace, ${toString ws}"
                  "$mod SHIFT, code:1${toString i}, split:movetoworkspace, ${toString ws}"
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
          no_hardware_cursors = true;
        };

        input = { 
          sensitivity = -0.112;
          float_switch_override_focus = 0;
          accel_profile = "flat";
          mouse_refocus = 1;
          follow_mouse = 2;
          off_window_axis_events = 0;
        };

        xwayland = {
          force_zero_scaling = true;
        };

        monitor = 
        [
          ", preferred, auto, auto"
          ", addreserved, -10, 0, 0, 0"  # trims margin to make top edge closer to waybar
          "DP-1, addreserved, -10, 560, 0, 0"
          "DP-1, 1920x1200, -1200x0, 1, transform, 1"
          "DP-2, 2560x1440@144, 0x0, 1"
          "DP-3, 1920x1080, 2560x0, 1"
        ];

      };

#      extraConfig = "
#             monitor = , preferred, auto, auto
#             monitor = DP-1, 1920x1200, -1200x0, 1, transform, 1
#             monitor = DP-2, 2560x1440@144, 0x0, 1
#             monitor = DP-3, 1920x1080, 2560x0, 1
#             ";
    };
  
  };
}


