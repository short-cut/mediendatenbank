#!/usr/bin/env bash

if [[ ! -d "${PROJECT_ROOT_DOCKER}/var/log/apache2" ]]; then
    echo "Create apache log-dir inside the application log-dir"
    mkdir -p "${PROJECT_ROOT_DOCKER}/var/log/apache2"
fi

if [[ -d "${PROJECT_ROOT_DOCKER}/var/cache" ]]; then
    echo "Clean up cache directories"
    rm -rf ${PROJECT_ROOT_DOCKER}/var/cache/*
fi

if [[ ! -d "${WWW_BASE_DIR}/cache" ]]; then
    echo "Create folder for session cache"
    mkdir "${WWW_BASE_DIR}/cache"
    chmod 777 "${WWW_BASE_DIR}/cache"
fi

chown "${APACHE_RUN_USER}":"${USER_GROUP_ID}" --recursive ${PROJECT_ROOT_DOCKER} && chmod g+w --recursive "${PROJECT_ROOT_DOCKER}"

echo "127.0.0.1 ${HOST_NAME}" >> /etc/hosts
echo "ServerName ${HOST_NAME}" >> /etc/apache2/apache2.conf

#/usr/local/bin/composer self-update

cd "${PROJECT_ROOT_DOCKER}" || echo "Cannot move into ${PROJECT_ROOT_DOCKER}"
if [[ ! -f ./var/log/apache2/error.log ]]; then
    touch ./var/log/error.log
fi
if [[ ! -f ./var/log/apache2/access.log ]]; then
    touch ./var/log/access.log
fi
if [[ ! -f  ./var/log/resourcespace.log ]]; then
    touch ./var/log/resourcespace.log
fi
chmod 666 ./var/log/resourcespace.log

echo "Adapt filestore permissions..."
chmod --recursive 777 ./filestore

echo "Prepare config.php for environment \"${ENVIRONMENT}\""
cp "./include/config.${ENVIRONMENT}.php" ./include/config.php

echo "starting cron"
service cron start
service cron restart

echo "Provisioning done!"

exec "$@"