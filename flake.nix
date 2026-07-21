{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  #inputs.nixpkgs.url = "/home/daniel-trnka/nixpkgs";
  inputs.nextbike.url = "github:trnila/nextbike_rides_viewer";
  inputs.assistant.url = "github:trnila/assistant";

  outputs =
    {
      self,
      nixpkgs,
      nextbike,
      assistant,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "armv7l-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      assistantTag = assistant.rev;
    in
    {
      nixosConfigurations.pi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";

        specialArgs = {
          inherit assistantTag;
        };
        modules = [
          {
            nixpkgs.overlays = [
              (final: prev: {
                linuxKernel = prev.linuxKernel // {
                  packagesFor = kernel: (prev.linuxKernel.packagesFor kernel).extend (lpfinal: lpprev: {
                    bcachefs = null;
                  });
                };
              })
            ];
          }
          ./configuration.nix
          nextbike.nixosModules.default

          (
            { modulesPath, ... }:
            {
              imports = [
                "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
              ];
              sdImage.compressImage = false;
            }
          )
        ];
      };

nixosConfigurations.hcm = nixpkgs.lib.nixosSystem {
        system = "armv7l-linux";
        modules = [
          {
            nixpkgs.buildPlatform = "x86_64-linux";
            nixpkgs.hostPlatform = "armv7l-linux";
            boot.loader.systemd-boot.enable = true;
            fileSystems = {
              "/" = {
                device = "/dev/disk/by-label/kokoti";
                fsType = "ext4";
              };
            };
          }

          ./configuration.nix

        ];
};

      sdImage = self.nixosConfigurations.pi.config.system.build.sdImage;

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.nixos-rebuild
              pkgs.prek
              pkgs.sops
            ];
          };
        }
      );
    };
}
