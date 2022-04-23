#!/bin/bash

COMPOSE_FILE=docker-compose.yml

readonly DOCKER_DIR='/var/opt/github/weseek/growi'
readonly BACKUP_DIR='/var/opt/backup'
readonly BACKUP_GEN=2

function remove_old_backup() {
    local target=$1

    ls -t ${BACKUP_DIR}/${target} | tail -n+$(expr ${BACKUP_GEN} + 1) | xargs rm -f
}

cd ${DOCKER_DIR}
docker-compose stop

CONTAINER_NAME='growi_app_1'
docker run --rm --volumes-from ${CONTAINER_NAME} -v ${BACKUP_DIR}:/var/opt/backup busybox tar cf /var/opt/backup/${CONTAINER_NAME}-growi_data-$(date '+%Y%m%d-%H%M%S').tar /data
remove_old_backup "${CONTAINER_NAME}-growi_data-*.tar"

CONTAINER_NAME='growi_mongo_1'
docker run --rm --volumes-from ${CONTAINER_NAME} -v ${BACKUP_DIR}:/var/opt/backup busybox tar cf /var/opt/backup/${CONTAINER_NAME}-mongo_configdb-$(date '+%Y%m%d-%H%M%S').tar /data/configdb
docker run --rm --volumes-from ${CONTAINER_NAME} -v ${BACKUP_DIR}:/var/opt/backup busybox tar cf /var/opt/backup/${CONTAINER_NAME}-mongo_db-$(date '+%Y%m%d-%H%M%S').tar /data/db
remove_old_backup "${CONTAINER_NAME}-mongo_configdb-*.tar"
remove_old_backup "${CONTAINER_NAME}-mongo_db-*.tar"

CONTAINER_NAME='growi_elasticsearch_1'
docker run --rm --volumes-from ${CONTAINER_NAME} -v ${BACKUP_DIR}:/var/opt/backup busybox tar cf /var/opt/backup/${CONTAINER_NAME}-es_data-$(date '+%Y%m%d-%H%M%S').tar /usr/share/elasticsearch/data
remove_old_backup "${CONTAINER_NAME}-es_data-*.tar"

docker-compose start

exit 0
