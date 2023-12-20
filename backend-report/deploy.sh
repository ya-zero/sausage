#!/bin/bash
set +e
echo "start"
cat > backend-report.env <<EOF
SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL}
SPRING_DATASOURCE_USERNAME=${SPRING_DATASOURCE_USERNAME}
SPRING_DATASOURCE_PASSWORD=${SPRING_DATASOURCE_PASSWORD}
VERSION=${VERSION}
SPRING_DATA_MONGODB_URI=${SPRING_DATA_MONGODB_URI}
PORT=8080
EOF
docker login -u $CI_REGISTRY_USER -p $CI_JOB_TOKEN $CI_REGISTRY
set -e
docker compose --env-file backend-report.env up --force-recreate --pull always --wait backend-report -d
