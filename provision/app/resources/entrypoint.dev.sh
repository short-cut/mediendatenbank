#!/usr/bin/env bash

if [[ ! -d "${PROJECT_ROOT_DOCKER}/var/log/apache2" ]]; then
    echo "Create apache log-dir inside the application log-dir"
    mkdir -p "${PROJECT_ROOT_DOCKER}/var/log/apache2"
fi

# cache cleanup
if [[ -d "${PROJECT_ROOT_DOCKER}/var/cache" ]]; then
    rm -rf ${PROJECT_ROOT_DOCKER}/var/cache/*
fi

if [[ ! -d ${PROJECT_ROOT_DOCKER}/var ]]; then
    mkdir ${PROJECT_ROOT_DOCKER}/var
fi

chown --recursive "${APACHE_RUN_USER}":"${APACHE_RUN_GROUP}" "${COMPOSER_CACHE_DIR_DOCKER}"
chown --recursive "${APACHE_RUN_USER}":"${APACHE_RUN_GROUP}" "${PROJECT_ROOT_DOCKER}/../.cache"
chown "${APACHE_RUN_USER}":"${USER_GROUP_ID}" --recursive ${PROJECT_ROOT_DOCKER} && chmod g+w --recursive "${PROJECT_ROOT_DOCKER}"

su -c "ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts" ${APACHE_RUN_USER}
echo "127.0.0.1 ${HOST_NAME}" >> /etc/hosts
echo "ServerName ${HOST_NAME}" >> /etc/apache2/apache2.conf

/usr/local/bin/composer self-update

cd "${PROJECT_ROOT_DOCKER}" || echo "Cannot move into ${PROJECT_ROOT_DOCKER}"
if [[ ! -f ./var/log/docker.log ]]; then
    touch ./var/log/docker.log
fi
if [[ ! -f ./var/log/apache2/error.log ]]; then
    touch ./var/log/error.log
fi
if [[ ! -f ./var/log/apache2/access.log ]]; then
    touch ./var/log/access.log
fi
if [[ ! -f var/log/docker.log ]]; then
    touch var/log/docker.log
fi

echo "Install vendors by calling composer install, result see var/log/docker.log"
su -s /bin/bash -c "APP_ENV=${ENVIRONMENT} composer install --optimize-autoloader" "${APACHE_RUN_USER}"

# echo "Install frontend assets with yarn, result see var/log/yarn.log"
# su -s /bin/bash -c "yarn install && yarn encore dev" ${APACHE_RUN_USER}

#echo "starting cron"
#chown root:root /etc/crontab
#chmod 600 /etc/crontab
#service cron start
#service cron restart

echo "Provisioning done!"

exec "$@"