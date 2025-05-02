{ config, pkgs, ... }:

{
  config.virtualisation.oci-containers.containers = {
    couchdb-livesync = {
      image = "apache/couchdb:latest";
      ports = [ "5984:5984" ];

    }
  }
}
