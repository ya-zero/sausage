#!/bin/bash
set +e
cat > backend.env <<EOF
SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL}
SPRING_DATASOURCE_USERNAME=${SPRING_DATASOURCE_USERNAME}
SPRING_DATASOURCE_PASSWORD=${SPRING_DATASOURCE_PASSWORD}
SPRING_DATA_MONGODB_URI=${SPRING_DATA_MONGODB_URI}
SPRING_CLOUD_VAULT_ENABLED=false
SPRING_FLYWAY_ENABLED=false
VERSION=latest
EOF

sudo usermod -aG docker student
docker login -u $CI_REGISTRY_USER -p $CI_JOB_TOKEN $CI_REGISTRY
set -e
echo 'BLUE and GREEN runs'
if [ "$( sudo docker container inspect -f '{{.State.Health.Status}}' student-backend-green-1 )" == "healthy" ] && [ "$( sudo docker container inspect -f '{{.State.Health.Status}}' student-backend-blue-1 )" == "healthy" ];
then sudo docker compose stop backend-green && sudo docker compose --env-file=backend.env up --force-recreate --pull always  backend-green -d
while [ "$( sudo docker container inspect -f '{{.State.Health.Status}}' student-backend-green-1 )" != "healthy" ]; do
        sleep 1;
done
sudo docker compose stop backend-blue; exit;
fi

echo 'BLUE and GREEN stopped'
if [ "$( sudo docker container inspect -f '{{.State.Health.Status}}' student-backend-green-1 )" == "unhealthy" ] && [ "$( sudo docker container inspect -f '{{.State.Health.Status}}' student-backend-blue-1 )" == "unhealthy" ];
then sudo docker compose stop backend-green && sudo docker compose --env-file=backend.env up --force-recreate --pull always -d backend-green
while [ "$( sudo docker container inspect -f '{{.State.Health.Status}}' student-backend-green-1 )" != "healthy" ]; do
        sleep 1;
done
exit;
fi

echo 'BLUE runs GREEN stopped'
if [ "$( sudo docker container inspect -f '{{.State.Health.Status}}' student-backend-green-1 )" == "unhealthy" ] && [ "$( sudo docker container inspect -f '{{.State.Health.Status}}' student-backend-blue-1 )" == "healthy" ];
then sudo docker compose --env-file=backend.env up --force-recreate --pull always -d backend-green
while [ "$( sudo docker container inspect -f '{{.State.Health.Status}}' student-backend-green-1 )" != "healthy" ]; do
        sleep 1;
done
sudo docker compose stop backend-blue; exit;
fi


echo 'BLUE stopped GREEN runs'
if [ "$( sudo docker container inspect -f '{{.State.Health.Status}}' student-backend-green-1 )" == "healthy" ] && [ "$( sudo docker container inspect -f '{{.State.Health.Status}}' student-backend-blue-1 )" == "unhealthy" ];
then sudo docker compose --env-file=backend.env up --force-recreate --pull always -d backend-blue
while [ "$( sudo docker container inspect -f '{{.State.Health.Status}}' student-backend-blue-1 )" != "healthy" ]; do
        sleep 1;
done
sudo docker compose stop backend-green; exit;
fi

#docker compose  --env-file backend.env up --force-recreate --pull always  backend -d
