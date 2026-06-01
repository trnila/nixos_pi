{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nextbike.url = "github:trnila/nextbike_rides_viewer/nix";
  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  outputs =
    {
      self,
      nixpkgs,
      nextbike,
      deploy-rs,
    }:
    {
      nixosConfigurations.picko = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
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

      sdImage = self.nixosConfigurations.picko.config.system.build.sdImage;

      deploy.nodes.pi = {
        #hostname = "pi.trnila.eu";
        hostname = "nix";
        profiles.system = {
          user = "root";
          sshUser = "root";
          path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.picko;
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
