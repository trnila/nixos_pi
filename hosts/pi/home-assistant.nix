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

        # thread/matter
        python-otbr-api
        universal-silabs-flasher
        ha-silabs-firmware-client
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

  services.openthread-border-router = {
    enable = true;
    backboneInterfaces = [ "end0" ];
    web.enable = true;
    radio = {
      device = "/dev/serial/by-id/usb-Espressif_USB_JTAG_serial_debug_unit_40:4C:CA:45:32:54-if00";
    };
  };
  services.matterjs-server = {
    enable = true;
    extraArgs = [ "--primary-interface=wpan0" ];
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
