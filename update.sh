#!/usr/bin/env bash
set -ex
nix flake update
git add flake.lock
git commit -m "flake: update nixpkgs"
