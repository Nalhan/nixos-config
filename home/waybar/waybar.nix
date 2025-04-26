{ ... }: {

  programs.waybar = {
      enable = true;
      style = builtins.readFile ../waybar/style.css;
      settings = [{
        layer = "top";
        position = "top";
        mod = "dock";
        exclusive = true;
        passtrough = false;
        gtk-layer-shell = true;
        height = 0;
        modules-left = [
          "hyprland/workspaces"
          "custom/divider"
          "cpu"
          "custom/divider"
          "memory"
        ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "tray"
          "custom/divider"
          "clock"
        ];
        "hyprland/window" = { format = "{}"; };
        "wlr/workspaces" = {
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
          all-outputs = true;
          on-click = "activate";
        };
        battery = { format = "󰁹 {}%"; };
        cpu = {
          interval = 10;
          format = "󰻠 {}%";
          max-length = 10;
          on-click = "";
        };
        memory = {
          interval = 30;
          format = "  {}%";
          format-alt = " {used:0.1f}G";
          max-length = 10;
        };
        tray = {
          icon-size = 13;
          tooltip = false;
          spacing = 10;
        };

        clock = {
          format = " {:%I:%M %p   %m/%d} ";
          tooltip-format = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
        };

        "custom/divider" = {
          format = " | ";
          interval = "once";
          tooltip = false;
        };
        "custom/endright" = {
          format = "_";
          interval = "once";
          tooltip = false;
        };
      }];
    };
}
