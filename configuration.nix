{
  config,
  lib,
  pkgs,
  assistantTag,
  ...
}:

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

  boot.extraModulePackages = [
    (pkgs.callPackage ./seeed-voicecard.nix {
      kernel = config.boot.kernelPackages.kernel;
    })
  ];

  system.stateVersion = "26.05";
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  hardware.deviceTree.enable = true;
  hardware.deviceTree.overlays = [
    {
      name = "disable-bt-and-enable-serial";
      dtsFile = ./dts/disable-bt-and-enable-serial.dts;
    }
    {
      name = "seeed-8mic-voicecard";
      dtsFile = ./dts/seeed-8mic-voicecard.dts;
    }
  ];
  hardware.bluetooth.enable = true;

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "pi2";
  networking.networkmanager.enable = false;
  networking.useNetworkd = true;
  systemd.network.networks."90-end0" = {
    matchConfig.Name = "end0";
    address = [
    ];
    networkConfig = {
      DHCP = "yes";
    };
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
      6053
    ];
  };
  time.timeZone = "Europe/Prague";

  environment.systemPackages = with pkgs; [
    vim
    wget
    htop
    ncdu
    ripgrep
    minicom
    dtc
    git
    gnumake
    alsa-utils
    gcc
    python3
  ];

  systemd.oomd = {
    enable = true;
    enableRootSlice = true;
    enableSystemSlice = true;
    enableUserSlices = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    systemWide = true;
    pulse.enable = true;
  };

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  services.openssh.settings.PasswordAuthentication = false;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDacshL0MKcPH/C0S7/ybYcd7+643Lo6X9VjAkwdgOCw3FKYWr20qKCHd0hPFXcYixt86aNuF2McNRae5h+dlPwPWIuJTt987gnp25IQlsWBeIiS1tDZI1lZcVu+Yj7BQMmp8uXkyP4KqjX9zaa3FmXv4MeWz/41rRYj72A1ZlsF1H/SxZ7uQX27XuhV5nOvsH2yAbXKexDwcvcR/lrxQcYH9el3QDt6x229lqn9piuSSl/LYAN81jxd/4a2Pwrnqeqca+HC9xY6LF6NW64E2RkZMMTbsaFo8E4FFLnTzcYgP1+EKypPiphMhvCJQLOo3crcxMpv9eOGvgGh8iMdak3"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDHPnrZgImCAprHnZQaIyn6Wvvl+YDEjHmm0B8F/TVz57G6E7fHD/Cc8VJ571j1sQ/OeJhSWGm94itmEBBJNx8uoKcVtXvd+7Uow+Ui45KpEGCuMAB+3PdZd6+yzr6yTXr121+//XYAn0bYhAmyijVSMxBZ5gwohmrSg+P2uArhvmuEmn2r5kJ5KCb1tyj2713bhVm/4bFs+q+fHcKRG/0/CyfOPFn8wGfKpjvmmAc1knbzn6zzLOn2tjhA4Y2KEnJuU13ZLvqJLBHXp50LwA0kRDD2irX+6ZJD5KY/JpbzVX5vdgSXUbwAEGeecnU5o7KgXWb61YetRJhi8vu6Q0bxSoG7l1q2XFo8n9mV3TBofFgn4F+nudS9iQ7Cl6To7hi3/0zHnE4M4PVt7idC4BcLyEwGp3rwPApjiuYO7Io3oFTYYv6OORDq788s+FHPDKoHnw2JY/qcEZYQNx9+iIeJhMpBvm2+g7Ysn2NyPoFsB6qg/ZF1TnXdu07t6pngp1E="
  ];

  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--ssh" ];
  };
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
  services.thelounge.enable = true;
  services.octoprint.enable = true;
  services.redis.enable = true;
  services.nextbike-rides-viewer.enable = true;
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
          printer = {
            rule = "Host(`3dprinter.trnila.eu`)";
            entryPoints = [ "https" ];
            service = "octoprint";
          };
          hass = {
            rule = "Host(`hass.trnila.eu`)";
            entryPoints = [ "https" ];
            service = "hass";
          };
          thelounge = {
            rule = "Host(`trnila.eu`) && PathPrefix(`/irc/`)";
            entryPoints = [ "https" ];
            middlewares = [ "strip-irc" ];
            service = "thelounge";
          };
          nextbike = {
            rule = "Host(`trnila.eu`) && PathPrefix(`/nextbike`)";
            entryPoints = [ "https" ];
            middlewares = [ "strip-nextbike" ];
            service = "nextbike";
          };
        };

        services = {
          octoprint = {
            loadBalancer = {
              servers = [
                { url = "http://localhost:5000"; }
              ];
            };
          };

          hass = {
            loadBalancer = {
              servers = [
                { url = "http://localhost:8123"; }
              ];
            };
          };

          thelounge = {
            loadBalancer = {
              servers = [
                { url = "http://localhost:9000"; }
              ];
            };
          };
          nextbike = {
            loadBalancer = {
              servers = [
                { url = "http://localhost:8080"; }
              ];
            };
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

          strip-irc = {
            stripprefix = {
              prefixes = [ "/irc" ];
            };
          };

          strip-nextbike = {
            stripprefix = {
              prefixes = [ "/nextbike" ];
            };
          };
        };
      };
    };
  };

  users.users.traefik = {
    extraGroups = [ "podman" ];
  };

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
