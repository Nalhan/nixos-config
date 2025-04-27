{ config, lib, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    #systemd = {
    #  enable = false;
    #  target = "graphical-session.target";
    #};
    # Reference the CSS file located in the same directory
    style = builtins.readFile ./style.css;
    settings = {
      mainBar = {
        #output = "DP-2";
        layer = "top";
        position = "top";
        reload_style_on_change = true;
        modules-left = ["custom/notification" "clock" "tray"];
        modules-center = ["hyprland/workspaces"];
        modules-right = ["group/expand" "network"];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            active = "█";
            default = "";
            empty = "";
          };
          all-outputs = false;
          sort-by-number = true;
          persistent-workspaces = {
            "DP-1" = [1 2 3];
            "DP-2" = [7 8 9];
            "DP-3" = [13 14 15];
          };
        };

        "custom/notification" = {
          tooltip = false;
          format = "";
          on-click = "swaync-client -t -sw";
          escape = true;
        };

        "clock" = {
          format = "{:%I:%M%p} ";
          interval = 20;
          tooltip-format = "<tt>{calendar}</tt>";
          calendar = {
            format = {
              today = "<span color='#fAfBfC'><b>{}</b></span>";
            };
          };
          actions = {
            on-click-right = "shift_down";
            on-click = "shift_up";
          };
        };

        "network" = {
          format-wifi = "";
          format-ethernet = "";
          format-disconnected = "";
          tooltip-format-disconnected = "Error";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          tooltip-format-ethernet = "{ifname} 🖧 ";
          on-click = "${pkgs.kitty}/bin/kitty ${pkgs.networkmanager}/bin/nmtui";
        };

        "custom/expand" = {
          format = "";
          tooltip = false;
        };

        "custom/endpoint" = {
          format = "|";
          tooltip = false;
        };

        "group/expand" = {
          orientation = "horizontal";
          drawer = {
            transition-duration = 600;
            transition-to-left = true;
            click-to-reveal = true;
          };
          modules = ["custom/expand" "custom/colorpicker" "cpu" "memory" "temperature" "custom/endpoint"];
        };

        "custom/colorpicker" = {
          format = "{}";
          return-type = "json";
          interval = "once";
          exec = "${config.xdg.configHome}/waybar/scripts/colorpicker.sh -j";
          on-click = "${config.xdg.configHome}/waybar/scripts/colorpicker.sh";
          signal = 1;
        };

        "cpu" = {
          format = "󰻠";
          tooltip = true;
        };

        "memory" = {
          format = "";
        };

        "temperature" = {
          critical-threshold = 80;
          format = "";
        };

        "tray" = {
          icon-size = 14;
          spacing = 10;
        };
      };
    };
  };

  # Make scripts directory available in the waybar config directory
  home.file = {
    "${config.xdg.configHome}/waybar/scripts/colorpicker.sh" = {
      source = ./scripts/colorpicker.sh;
      executable = true;
    };
  };
  
  # Ensure all necessary dependencies are installed for the colorpicker script
  home.packages = with pkgs; [
    # For colorpicker script
    hyprpicker
    wl-clipboard
    libnotify
    
    grim
    slurp
  ];
}
