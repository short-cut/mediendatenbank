#!/usr/bin/env bash

chown --recursive ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} ${COMPOSER_CACHE_DIR_DOCKER}
chown --recursive ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} ${PROJECT_ROOT_DOCKER}/../.cache
chown ${APACHE_RUN_USER}:${USER_GROUP_ID} --recursive ${PROJECT_ROOT_DOCKER} && chmod g+w --recursive ${PROJECT_ROOT_DOCKER}

# cache cleanup
if [[ -d ${PROJECT_ROOT_DOCKER}/var/cache ]]; then
    rm -rf ${PROJECT_ROOT_DOCKER}/var/cache/*
fi

if [[ ! -d ${PROJECT_ROOT_DOCKER}/var ]]; then
    mkdir ${PROJECT_ROOT_DOCKER}/var
fi
echo "Change permissions to the dev with the groupId ${USER_GROUP_ID}"
chown -R ${APACHE_RUN_USER}:${USER_GROUP_ID} ${PROJECT_ROOT_DOCKER}/var && chmod --recursive g+w ${PROJECT_ROOT_DOCKER}/var/
chown -R ${APACHE_RUN_USER}:${USER_GROUP_ID} ${PROJECT_ROOT_DOCKER}/public && chmod --recursive g+w ${PROJECT_ROOT_DOCKER}/public/

/usr/local/bin/composer self-update

echo "127.0.0.1     ${HOST_NAME}" >> /etc/hosts
echo "ServerName ${HOST_NAME}" >> /etc/apache2/apache2.conf

cd "${PROJECT_ROOT_DOCKER}"
if [[ ! -f var/log/docker.log ]]; then
    touch var/log/docker.log
fi
if [[ ! -f var/log/docker.log ]]; then
    touch var/log/docker.log
fi

echo "Install vendors by calling composer install, result see var/log/docker.log"
su -s /bin/bash -c "composer install" ${APACHE_RUN_USER} 1>var/log/docker.log 2>&1
su -s /bin/bash -c "APP_ENV=${ENVIRONMENT} composer install --optimize-autoloader --classmap-authoritative" ${APACHE_RUN_USER} > /dev/null

echo "Install frontend assets with yarn, result see var/log/yarn.log"
su -s /bin/bash -c "yarn install && yarn encore production" ${APACHE_RUN_USER} 1>var/log/yarn.log 2>&1

#    su -s /bin/bash -c "php bin/console ibexa:graphql:generate-schema --env=${ENVIRONMENT}"
#    echo "Reindex content to Solr"
#    su -s /bin/bash -c "php bin/console ibexa:reindex --env=${ENVIRONMENT}" ${APACHE_RUN_USER}

#echo "starting cron"
#chown root:root /etc/crontab
#chmod 600 /etc/crontab
#service cron start
#service cron restart

echo "Provisioning done!"

exec "$@"