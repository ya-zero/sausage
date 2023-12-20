#!/bin/bash
set +e
cat > frontend.env <<EOF
VERSION=${VERSION}
EOF
sudo usermod -aG docker student
docker login -u $CI_REGISTRY_USER -p $CI_JOB_TOKEN $CI_REGISTRY
set -e
docker compose  --env-file frontend.env up --force-recreate --pull always --wait frontend -d

