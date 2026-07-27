{ pkgs, assistantTag, ... }:
{
  services.redis.enable = true;
  virtualisation.oci-containers = {
    backend = "podman";
    containers.lunch = {
      image = "ghcr.io/trnila/assistant:${assistantTag}";
      extraOptions = [
        "--network=host"
      ];
      cmd = [
        "--port"
        "5001"
      ];
      labels = {
        "traefik.enable" = "true";
        "traefik.http.services.lunch-backend.loadbalancer.server.port" = "5001";

        "traefik.http.routers.lunch-frontend.rule" = "Host(`trnila.eu`) && Path(`/lunch`)";
        "traefik.http.routers.lunch-frontend.service" = "lunch-backend";
        "traefik.http.routers.lunch-frontend.middlewares" = "lunch-strip";
        "traefik.http.middlewares.lunch-strip.stripprefix.prefixes" = "/lunch";

        "traefik.http.routers.lunch-backend.rule" = "Host(`trnila.eu`) && Path(`/lunch.json`)";
        "traefik.http.routers.lunch-backend.service" = "lunch-backend";

        "traefik.http.routers.assistant.rule" = "Host(`trnila.eu`) && PathPrefix(`/assistant/`)";
        "traefik.http.routers.assistant.middlewares" = "assistant-strip";
        "traefik.http.middlewares.assistant-strip.stripprefix.prefixes" = "/assistant";
        "traefik.http.routers.assistant.service" = "lunch-backend";
      };
      #user = "nobody";
    };
  };

  systemd.services.lunch-refetch = {
    description = "Re-fetch lunch data";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.curl}/bin/curl -X POST https://trnila.eu/lunch.json";
    };
  };
  systemd.timers.lunch-refetch = {
    description = "Run lunch-refetch every day in the morning";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Mon..Fri *-*-* 07..11:00:00";
      Persistent = true;
    };
  };
}
