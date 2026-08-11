{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    extraConfig.pipewire."91-null-audio-sink" = {
      "context.modules" = [
        {
          name = "libpipewire-module-null-audio-sink";
          args = {
            node.name = "virtual-sink";
            media.class = "Audio/Sink";
            audio.position = [ "FL" "FR" ];
          };
        }
      ];
    };
  };
}
