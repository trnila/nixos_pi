{ ... }:

{
  services.thelounge.enable = true;

  services.traefik.dynamicConfigOptions.http.routers.thelounge = {
    rule = "Host(`trnila.eu`) && PathPrefix(`/irc/`)";
    entryPoints = [ "https" ];
    middlewares = [ "strip-irc" ];
    service = "thelounge";
  };
  services.traefik.dynamicConfigOptions.http.services.thelounge = {
    loadBalancer = {
      servers = [
        { url = "http://localhost:9000"; }
      ];
    };
  };

  services.traefik.dynamicConfigOptions.http.middlewares.strip-irc = {
    stripprefix = {
      prefixes = [ "/irc" ];
    };
  };
}
