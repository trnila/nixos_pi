# esphome configuration

This repository contains ESPHome configurations for devices such as bedroom light, kitchen light or Bluetooth proxy.

Passwords, tokens, and other secrets are stored in `secrets.yaml` and encrypted with `sops`.
If you use a different SSH key, set it with:
```sh
$ export SOPS_AGE_SSH_PRIVATE_KEY_FILE="$HOME/.ssh/my_key"
```

To edit or view secrets:
```sh
$ sops edit secrets.yaml
```

You can `compile`, `upload`, or do both (`run`) for a specific device:
```sh
$ ./esphome.sh run kitchen-light.yaml
```
