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
}
