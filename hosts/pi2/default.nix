{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../common.nix
  ];

  system.stateVersion = "26.05";
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  hardware.deviceTree.enable = true;
  hardware.deviceTree.overlays = [
    {
      name = "disable-bt-and-enable-serial";
      dtsFile = ../../dts/disable-bt-and-enable-serial.dts;
    }
    {
      name = "seeed-8mic-voicecard";
      dtsFile = ../../dts/seeed-8mic-voicecard.dts;
    }
  ];

  boot.extraModulePackages = [
    (pkgs.seeed-voicecard config.boot.kernelPackages.kernel)
  ];

  # fix booting from SSD over USB3
  boot.kernelParams = [
    "usb-storage.quirks=152d:1576:u"
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "pi2";
  systemd.network.networks."90-end0" = {
    matchConfig.Name = "end0";
    address = [
      "192.168.1.227/24"
      "2001:470:5816::1:2/64"
    ];
    networkConfig = {
      DHCP = "yes";
    };
  };

  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--ssh" ];
  };

  services.prometheus.exporters.node.enable = true;
}
