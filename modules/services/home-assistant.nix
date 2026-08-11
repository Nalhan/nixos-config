{
  services.home-assistant = {
    enable = true;
    openFirewall = true;
    extraComponents = [
      "esphome"
      "matter"
      "met"
      "radio_browser"
      "wled"
      "zha"
      "zwave_js"
    ];
    config = {
      default_config = { };
      http = {
        server_port = 8123;
      };
      "automation manual" = [ ];
      "automation ui" = "!include automations.yaml";
    };
  };
}
