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
        wyoming
      ];
  };

  # Text-to-speech
  services.wyoming.piper.servers.default = {
    enable = true;
    uri = "tcp://127.0.0.1:10200";
    voice = "en_US-norman-medium";
  };

  # Speech-to-text
  services.wyoming.faster-whisper.servers.default = {
    enable = true;
    model = "small.en";
    language = "en";
    uri = "tcp://127.0.0.1:10300";
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
