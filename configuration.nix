# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim
    wget
    htop
    #chromium
    #ripgrep
  ];

  services.octoprint.enable = true;
  services.redis.enable = true;
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      log.level = "DEBUG";
      entryPoints = {
        web = {
          address = ":80";
        };
      };
      api.dashboard = true;
      api.insecure = true;
      providers = {
        docker = {
          endpoint = "unix:///run/podman/podman.sock";
          exposedByDefault = false;
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
      image = "ghcr.io/trnila/assistant:latest";
      extraOptions = [
        "--network=host"
      ];
      cmd = [
        "--port"
        "5001"
      ];
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.lunch.rule" = "PathPrefix(`/lunch`)";
        "traefik.http.middlewares.lunch-strip.stripprefix.prefixes" = "/lunch";
        "traefik.http.routers.lunch.middlewares" = "lunch-strip";
        "traefik.http.services.lunch.loadbalancer.server.port" = "5001";
      };
      #user = "nobody";
    };

  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDacshL0MKcPH/C0S7/ybYcd7+643Lo6X9VjAkwdgOCw3FKYWr20qKCHd0hPFXcYixt86aNuF2McNRae5h+dlPwPWIuJTt987gnp25IQlsWBeIiS1tDZI1lZcVu+Yj7BQMmp8uXkyP4KqjX9zaa3FmXv4MeWz/41rRYj72A1ZlsF1H/SxZ7uQX27XuhV5nOvsH2yAbXKexDwcvcR/lrxQcYH9el3QDt6x229lqn9piuSSl/LYAN81jxd/4a2Pwrnqeqca+HC9xY6LF6NW64E2RkZMMTbsaFo8E4FFLnTzcYgP1+EKypPiphMhvCJQLOo3crcxMpv9eOGvgGh8iMdak3"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDHPnrZgImCAprHnZQaIyn6Wvvl+YDEjHmm0B8F/TVz57G6E7fHD/Cc8VJ571j1sQ/OeJhSWGm94itmEBBJNx8uoKcVtXvd+7Uow+Ui45KpEGCuMAB+3PdZd6+yzr6yTXr121+//XYAn0bYhAmyijVSMxBZ5gwohmrSg+P2uArhvmuEmn2r5kJ5KCb1tyj2713bhVm/4bFs+q+fHcKRG/0/CyfOPFn8wGfKpjvmmAc1knbzn6zzLOn2tjhA4Y2KEnJuU13ZLvqJLBHXp50LwA0kRDD2irX+6ZJD5KY/JpbzVX5vdgSXUbwAEGeecnU5o7KgXWb61YetRJhi8vu6Q0bxSoG7l1q2XFo8n9mV3TBofFgn4F+nudS9iQ7Cl6To7hi3/0zHnE4M4PVt7idC4BcLyEwGp3rwPApjiuYO7Io3oFTYYv6OORDq788s+FHPDKoHnw2JY/qcEZYQNx9+iIeJhMpBvm2+g7Ysn2NyPoFsB6qg/ZF1TnXdu07t6pngp1E="

  ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
