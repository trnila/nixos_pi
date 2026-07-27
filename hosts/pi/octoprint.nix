{ lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      octoprint = prev.octoprint.override {
        packageOverrides = self: super: {
          octoprint = super.octoprint.overridePythonAttrs (oldAttrs: {
            propagatedBuildInputs = (lib.remove self.class-doc (oldAttrs.propagatedBuildInputs or [ ])) ++ [
              self.more-itertools
            ];
          });

          octoprint-filecheck = super.octoprint-filecheck.overridePythonAttrs (oldAttrs: {
            version = "2025.7.23";

            src = final.fetchFromGitHub {
              owner = "OctoPrint";
              repo = "OctoPrint-FileCheck";
              rev = "2025.7.23";
              hash = "sha256-Y3JVfbe+bZz2t65OqdjvVVqTSa0VUPoCaxvE+zQ+Qts=";
            };
          });

          octoprint-firmwarecheck = super.octoprint-firmwarecheck.overridePythonAttrs (oldAttrs: {
            version = "2025.7.23";

            src = final.fetchFromGitHub {
              owner = "OctoPrint";
              repo = "OctoPrint-FirmwareCheck";
              rev = "2025.7.23";
              hash = "sha256-QPchpyeotB5IKbfES74CJlhw3sz8Q1df/+n5dpbrHSs=";
            };
          });

          octoprint-pisupport = super.octoprint-pisupport.overridePythonAttrs (oldAttrs: {
            version = "2025.7.23";

            src = final.fetchFromGitHub {
              owner = "OctoPrint";
              repo = "OctoPrint-PiSupport";
              rev = "2025.7.23";
              hash = "sha256-bXjRGxIwi+UnVts2HO9viOJqa2AmZ/CL7wuoyzRbAEw=";
            };
          });
        };
      };
    })
  ];

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
