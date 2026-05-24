{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nextbike.url = "github:trnila/nextbike_rides_viewer/nix";
  outputs =
    { self, nixpkgs, nextbike }:
    {
	nixosConfigurations.picko = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./configuration.nix
          nextbike.nixosModules.default
        
           ({ modulesPath, ... }: {
          imports = [
            "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
          ];
          sdImage.compressImage = false;
        })
        
        ];
      };

      sdImage =
      self.nixosConfigurations.picko.config.system.build.sdImage;
    };
}
