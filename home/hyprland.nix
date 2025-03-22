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
      
      monitor = [
        ", preferred, auto, auto"
        "DP-1, 1920x1200, 0x0, 1, transform, 1"
      ];

      bind =
        [
          "$mod, Q, exec, $terminal"
          "$mod, SPACE, exec, $menu"
          "$mod, F, exec, firefox"
        ]
        ++ (
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
          };
      #    extraConfig = "
       #     monitor = , preferred, auto, auto
#            monitor = DP-1, 1920x1200, 0x0, 1, transform, 1
 #           ";
  };
}
