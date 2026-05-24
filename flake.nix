{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs =
    { self, nixpkgs }:
    {
      nixosConfigurations.picko = nixpkgs.lib.nixosSystem {
        modules = [
          (
            { pkgs, ... }:
            {
              nixpkgs.buildPlatform.system = "x86_64-linux";
              nixpkgs.hostPlatform = "aarch64-linux";
            }
          )

          ./configuration.nix
        ];
      };
    };
}
