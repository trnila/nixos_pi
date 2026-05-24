# NixOS on `pi.trnila.eu`

NixOS configuration for `pi.trnila.eu`.

## Manual deployment

Enter the environment by running:
```sh
$ nix develop
```

The configuration can be manually deployed by running:
```sh
$ ./deploy.sh
```

The SD card image can be created with:
```sh
$ nix build .#sdImage
```

## Deploy from CI
Every merge into master automatically deploys the current configuration to a Raspberry Pi by creating a ephemeral Tailscale node using an OAuth token.
The ephemeral node uses Tailscale SSH access grants instead of SSH keys/passwords to connect to the Raspberry Pi, builds the Nix configuration directly on the device, and performs the system switch in place.
