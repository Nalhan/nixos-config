{ config, pkgs, ... }:

{ 
  config.virtualisation.oci-containers.containers = {
    jellyfin = {
      image = "lscr.io/linuxserver/jellyfin:latest";
      ports = [
        "8096:8096"
        "8920:8920"   # optional
        "7359:7359/udp" # optional
        "1900:1900/udp" # optional
      ];
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "America/Los_Angeles";
        #JELLYFIN_PublishedServerUrl = "http://192.168.0.5"; # optional
      };
      volumes = [
        "/etc/nixos/modules/containers/jellyfin/config:/config"
        #"/path/to/tvseries:/data/tvshows"
        #"/path/to/movies:/data/movies"
      ];
      #restartPolicy = "unless-stopped"; this is not real
    };
  };
}
