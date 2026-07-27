{
  config,
  lib,
  ...
}:
let
  domain = "grafana.trnila.eu";
  port = 3000;
in
{
  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.prometheus.exporters.node.port}"
              "pi2:${toString config.services.prometheus.exporters.node.port}"
            ];
          }
        ];
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = port;
        enforce_domain = true;
        enable_gzip = true;
        domain = domain;
      };
      security.secret_key = "$__file{/etc/secrets/grafana_secret_key}";
    };
    provision = {
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
          isDefault = true;
          editable = false;
        }
      ];
    };
  };

  services.traefik.dynamicConfigOptions.http.routers.grafana = {
    rule = "Host(`${domain}`)";
    entryPoints = [ "https" ];
    service = "grafana";
  };

  services.traefik.dynamicConfigOptions.http.services.grafana = {
    loadBalancer = {
      servers = [
        { url = "http://localhost:${toString port}"; }
      ];
    };
  };
}
