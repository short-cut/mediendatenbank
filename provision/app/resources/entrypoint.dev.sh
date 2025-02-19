#!/usr/bin/env bash

if [[ ! -d "${PROJECT_ROOT_DOCKER}/var/log/apache2" ]]; then
    echo "Create apache log-dir inside the application log-dir"
    mkdir -p "${PROJECT_ROOT_DOCKER}/var/log/apache2"
fi

if [[ -d "${PROJECT_ROOT_DOCKER}/var/cache" ]]; then
    echo "Clean up cache directories"
    rm -rf ${PROJECT_ROOT_DOCKER}/var/cache/*
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

echo "Provisioning done!"

exec "$@"