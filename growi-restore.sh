#!/bin/bash

COMPOSE_FILE=docker-compose.yml

readonly DOCKER_DIR='/var/opt/github/weseek/growi'
readonly BACKUP_DIR='/var/opt/backup'

function info() {
    logger -s "$(basename $0): $@"
}

function error() {
    logger -s "$(basename $0): ERROR: $@"
}

function abort() {
    error $@
    exit 1
}

function restore() {
    local container_name=$1
    local file_name=$2

    echo -e "\n* Backup file list [container: ${container_name}][${file_name}]"
    cd ${BACKUP_DIR}
    ls -ltr ${file_name}
    echo '--------------------------------------------------'
    echo -n 'Input backup filename: '
    read backup_file || abort 'read faild.'
    [ -f ${backup_file} ] || abort "file ${backup_file} not found."
    docker run --rm --volumes-from ${container_name} -v ${BACKUP_DIR}:/var/opt/backup busybox tar xf /var/opt/backup/${backup_file}
    echo "Resotore done. [container: ${container_name}][${backup_file}]"
}

info '##### GROWI restore start. #####'

cd ${DOCKER_DIR}
docker-compose down -v || abort 'docker-compose down -v faild.'
docker-compose up --no-start || abort 'docker-compose up --no-start faild.'

restore 'growi_app_1' 'app_data_????????-??????.tar'
restore 'growi_mongo_1' 'mongo_configdb_????????-??????.tar'
restore 'growi_mongo_1' 'mongo_db_????????-??????.tar'
restore 'growi_elasticsearch_1' 'elasticsearch_data_????????-??????.tar'

cd ${DOCKER_DIR}
docker-compose start || abort 'docker-compose start faild.'

info '##### GROWI restore completed successfully. #####'

exit 0
