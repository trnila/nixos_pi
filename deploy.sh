#!/usr/bin/env bash
set -ex

DEPLOY_HOST=${1:-pi}
nixos-rebuild --flake .#pi --target-host "$DEPLOY_HOST" --build-host "$DEPLOY_HOST" --no-reexec switch
