{ lib, ... }:
{
  services.octoprint.enable = true;
  services.traefik.dynamicConfigOptions.http.routers.octoprint = {
    rule = "Host(`3dprinter.trnila.eu`)";
    entryPoints = [ "https" ];
    service = "octoprint";
  };
  services.traefik.dynamicConfigOptions.http.services.octoprint = {
    loadBalancer = {
      servers = [
        { url = "http://localhost:5000"; }
      ];
    };
  };
}
