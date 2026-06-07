#!/usr/bin/env bash
set -ex
BUILD_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/build

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
trap 'rm -f *.yaml' EXIT

# copy configs and decrypt secrets
cp -v ../*.yaml .
sops decrypt ../secrets.yaml > secrets.yaml

docker run --rm --privileged -v "${PWD}":/config --device=/dev/ttyUSB0 -it ghcr.io/esphome/esphome "$@"
