{ ... }: {

  
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "esphome"
      "met"
      "radio_browser"
      "wled"
      "zwave_js"
      "matter"
      "zha"
    ];
 configDir = "/etc/nixos/modules/homeassistant/config";
    config = {
      default_config = {};
      "automation manual" = [ ];
      "automation ui" = "!include automations.yaml";
    };
  };

  #make this port available
  networking.firewall.allowedTCPPorts = [ 8123 ];

}
