{ config, lib, ... }:

let
  domain = "parts.trnila.eu";
  port = 8083;
in
{
  services.part-db = {
    enable = true;
    virtualHost = domain;
    settings = {
      DEFAULT_URI = "https://${domain}/";
      TRUSTED_HOSTS = "^${lib.strings.escapeRegex domain}$";
    };
  };

  services.nginx.virtualHosts.${domain} = {
    listen = [
      {
        addr = "[::1]";
        inherit port;
      }
    ];
  };

  services.traefik.dynamicConfigOptions.http.routers.parts = {
    rule = "Host(`${domain}`)";
    entryPoints = [ "https" ];
    service = "parts";
  };
  services.traefik.dynamicConfigOptions.http.services.parts = {
    loadBalancer = {
      servers = [
        { url = "http://[::1]:${toString port}"; }
      ];
    };
  };

}
