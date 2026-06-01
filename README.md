# NixOS on pi.trnila.eu

The configuration can be remotely deployed by running:
```sh
$ nixos-rebuild --flake .#pi --target-host nix --build-host nix --no-reexec switch
```

The SDcard image can be created with:
```sh
$ nix build .#sdImage
```
