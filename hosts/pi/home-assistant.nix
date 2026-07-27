{ ... }:

{
  services.home-assistant = {
    enable = true;
    extraPackages =
      python3Packages: with python3Packages; [
        bthome-ble
        xiaomi-ble
        gtts
        pyoctoprintapi
        zlib-ng
        isal
      ];
  };

  services.traefik.dynamicConfigOptions.http.routers.home-assistant = {
    rule = "Host(`hass.trnila.eu`)";
    entryPoints = [ "https" ];
    service = "home-assistant";
  };
  services.traefik.dynamicConfigOptions.http.services.home-assistant = {
    loadBalancer = {
      servers = [
        { url = "http://localhost:8123"; }
      ];
    };
  };

}
