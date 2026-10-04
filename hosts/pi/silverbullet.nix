{ config, pkgs, ... }:

{
  services.silverbullet = {
    enable = true;
    listenPort = 3001;
  };
  services.traefik.dynamicConfigOptions.http.routers.notes = {
    rule = "Host(`notes.trnila.eu`)";
    entryPoints = [ "https" ];
    service = "notes";
  };
  services.traefik.dynamicConfigOptions.http.services.notes = {
    loadBalancer = {
      servers = [
        { url = "http://localhost:${toString config.services.silverbullet.listenPort}"; }
      ];
    };
  };
}
