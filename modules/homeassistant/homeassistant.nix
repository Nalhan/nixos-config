{ ... }: {

  
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "esphome"
      "wled"
    ];
    #configDir = "/etc/nixos/modules/homeassistant/config";
    config = {
      default_config = {};
    };
  };

  #make this port available
  networking.firewall.allowedTCPPorts = [ 8123 ];

}
