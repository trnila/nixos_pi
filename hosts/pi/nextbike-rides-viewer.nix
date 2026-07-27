{ ... }:

{
  services.nextbike-rides-viewer.enable = true;

  services.traefik.dynamicConfigOptions.http.routers.nextbike-rides-viewer = {
    rule = "Host(`trnila.eu`) && PathPrefix(`/nextbike`)";
    entryPoints = [ "https" ];
    middlewares = [ "strip-nextbike" ];
    service = "nextbike-rides-viewer";
  };

  services.traefik.dynamicConfigOptions.http.services.nextbike-rides-viewer = {
    loadBalancer = {
      servers = [
        { url = "http://localhost:8080"; }
      ];
    };
  };

  services.traefik.dynamicConfigOptions.http.middlewares.strip-nextbike = {
    stripprefix = {
      prefixes = [ "/nextbike" ];
    };
  };

}
