nixos-rebuild --flake .#picko --target-host nix --build-host nix  --fast switch

nix build .#sdImage
