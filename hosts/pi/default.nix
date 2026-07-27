{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../common.nix
    ./octoprint.nix
    ./home-assistant.nix
    ./lunch.nix
    ./thelounge.nix
    ./nextbike-rides-viewer.nix
    ./monitoring.nix
    ./traefik.nix
  ];

  system.stateVersion = "26.05";
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  hardware.deviceTree.enable = true;
  hardware.deviceTree.overlays = [
    {
      name = "disable-bt-and-enable-serial";
      dtsFile = ../../dts/disable-bt-and-enable-serial.dts;
    }
  ];
  hardware.bluetooth.enable = true;

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "pi";
  systemd.network.networks."90-end0" = {
    matchConfig.Name = "end0";
    address = [
      "192.168.1.3/24"
      "2001:470:5816::1:1/64"
    ];
    networkConfig = {
      DHCP = "yes";
    };
  };
  networking.firewall.enable = true;

  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--ssh" ];
  };

  services.prometheus.exporters.node.enable = true;
}
