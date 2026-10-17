{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";
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
      overlays = [ (import ./pkgs) ];
      pkgsFor =
        system:
        import nixpkgs {
          inherit system overlays;
        };
      assistantTag = assistant.rev;
    in
    {
      pkgs = forAllSystems pkgsFor;

      nixosConfigurations.pi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit assistantTag;
        };
        modules = [
          ./hosts/pi
          nextbike.nixosModules.default

          {
            nixpkgs.hostPlatform = "aarch64-linux";
            nixpkgs.overlays = overlays;
          }

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

      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
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
