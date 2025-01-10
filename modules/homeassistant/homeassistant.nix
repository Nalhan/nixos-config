{ ... }: {

  
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "esphome"
    ];
    config = {
      default_config = {};
    };
  };

  #make this port available
  networking.firewall.allowedTCPPorts = [ 8123 ];

}
