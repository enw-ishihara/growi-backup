#!/bin/bash

COMPOSE_FILE=docker-compose.yml

readonly DOCKER_DIR='/var/opt/github/weseek/growi'
readonly BACKUP_DIR='/var/opt/backup'
readonly BACKUP_GEN=7

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

function backup() {
    local container_name=$1
    local file_name=$2
    local target_dir=$3

    docker run --rm --volumes-from ${container_name} -v ${BACKUP_DIR}:/var/opt/backup busybox tar cf /var/opt/backup/${file_name} ${target_dir}
}

function remove_old_backup() {
    local target=$1

    ls -t ${BACKUP_DIR}/${target} | tail -n+$(expr ${BACKUP_GEN} + 1) | xargs rm -f
}

info '##### GROWI backup start. #####'

cd ${DOCKER_DIR}
docker-compose stop || abort 'docker-compose stop faild.'

backup 'growi-app-1' "app_data_$(date '+%Y%m%d-%H%M%S').tar" '/data'
backup 'growi-mongo-1' "mongo_configdb_$(date '+%Y%m%d-%H%M%S').tar" '/data/configdb'
backup 'growi-mongo-1' "mongo_db_$(date '+%Y%m%d-%H%M%S').tar" '/data/db'
backup 'growi-elasticsearch-1' "elasticsearch_data_$(date '+%Y%m%d-%H%M%S').tar" '/usr/share/elasticsearch/data'

cd ${DOCKER_DIR}
docker-compose start || abort 'docker-compose start faild.'

remove_old_backup 'app_data_*.tar'
remove_old_backup 'mongo_configdb_*.tar'
remove_old_backup 'mongo_db_*.tar'
remove_old_backup 'elasticsearch_data_*.tar'

info '##### GROWI backup completed successfully. #####'

exit 0
