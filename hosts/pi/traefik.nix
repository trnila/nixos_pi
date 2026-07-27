{ config, ... }:
{
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      log.level = "DEBUG";
      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entrypoint = {
            to = "https";
            scheme = "https";
          };
        };
        https = {
          address = ":443";
          http.tls.certResolver = "letsencrypt";
        };
      };
      certificatesResolvers.letsencrypt.acme = {
        email = "daniel.trnka@gmail.com";
        storage = "${config.services.traefik.dataDir}/acme.json";
        httpChallenge.entryPoint = "web";
      };
      #api.dashboard = true;
      #api.insecure = true;
      providers = {
        docker = {
          endpoint = "unix:///run/podman/podman.sock";
          exposedByDefault = false;
        };
      };
    };
    dynamicConfigOptions = {
      http = {
        routers = {
          trnila-root = {
            rule = "Host(`trnila.eu`) && Path(`/`)";
            entryPoints = [ "https" ];
            middlewares = [ "to-github" ];
            service = "noop@internal";
          };
        };

        middlewares = {
          to-github = {
            redirectRegex = {
              regex = ".+";
              replacement = "https://github.com/trnila";
              permanent = false;
            };
          };
        };
      };
    };
  };

  users.users.traefik = {
    extraGroups = [ "podman" ];
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
