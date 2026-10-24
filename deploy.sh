#!/usr/bin/env bash
set -ex

DEPLOY_HOST=${1}

if [ -z "$DEPLOY_HOST" ]; then
  echo "Usage: $0 <deploy-host>"
  exit 1
fi

nh os switch ".#$DEPLOY_HOST" --target-host "root@$DEPLOY_HOST" --build-host "root@$DEPLOY_HOST"
