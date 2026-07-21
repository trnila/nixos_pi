{
  config,
  lib,
  pkgs,
  assistantTag,
  ...
}:

{
  system.stateVersion = "26.05";
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.overlays = [
    (final: prev: {
      bcachefs-tools = prev.bcachefs-tools.overrideAttrs (old: {
        meta = (old.meta or {}) // {
          broken = true;
        };
      });
    })
  ];

  #hardware.deviceTree.enable = true;
  #boot.loader.grub.enable = false;
  #boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "pi";
  networking.networkmanager.enable = false;
  networking.useNetworkd = true;
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
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
    ];
  };
  time.timeZone = "Europe/Prague";

  environment.systemPackages = with pkgs; [
    vim
    wget
    htop
    ripgrep
    minicom
    dtc
  ];

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  services.openssh.settings.PasswordAuthentication = false;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDacshL0MKcPH/C0S7/ybYcd7+643Lo6X9VjAkwdgOCw3FKYWr20qKCHd0hPFXcYixt86aNuF2McNRae5h+dlPwPWIuJTt987gnp25IQlsWBeIiS1tDZI1lZcVu+Yj7BQMmp8uXkyP4KqjX9zaa3FmXv4MeWz/41rRYj72A1ZlsF1H/SxZ7uQX27XuhV5nOvsH2yAbXKexDwcvcR/lrxQcYH9el3QDt6x229lqn9piuSSl/LYAN81jxd/4a2Pwrnqeqca+HC9xY6LF6NW64E2RkZMMTbsaFo8E4FFLnTzcYgP1+EKypPiphMhvCJQLOo3crcxMpv9eOGvgGh8iMdak3"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDHPnrZgImCAprHnZQaIyn6Wvvl+YDEjHmm0B8F/TVz57G6E7fHD/Cc8VJ571j1sQ/OeJhSWGm94itmEBBJNx8uoKcVtXvd+7Uow+Ui45KpEGCuMAB+3PdZd6+yzr6yTXr121+//XYAn0bYhAmyijVSMxBZ5gwohmrSg+P2uArhvmuEmn2r5kJ5KCb1tyj2713bhVm/4bFs+q+fHcKRG/0/CyfOPFn8wGfKpjvmmAc1knbzn6zzLOn2tjhA4Y2KEnJuU13ZLvqJLBHXp50LwA0kRDD2irX+6ZJD5KY/JpbzVX5vdgSXUbwAEGeecnU5o7KgXWb61YetRJhi8vu6Q0bxSoG7l1q2XFo8n9mV3TBofFgn4F+nudS9iQ7Cl6To7hi3/0zHnE4M4PVt7idC4BcLyEwGp3rwPApjiuYO7Io3oFTYYv6OORDq788s+FHPDKoHnw2JY/qcEZYQNx9+iIeJhMpBvm2+g7Ysn2NyPoFsB6qg/ZF1TnXdu07t6pngp1E="
  ];
}
