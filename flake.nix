{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
