#!/bin/bash

# リストア手順
# 1. コンテナとデータボリュームを削除する
#   docker-compose down -v
# 2. コンテナとデータボリュームを作成する
#   docker-compose up --no-start
# 3. データのリストアを実行する
#   growi-restore.sh growi_app_1 /var/opt/backup/[BACKUP_FILE]
#   growi-restore.sh growi_mongo_1 /var/opt/backup/[BACKUP_FILE]
#   growi-restore.sh growi_mongo_1 /var/opt/backup/[BACKUP_FILE]
#   growi-restore.sh growi_elasticsearch_1 /var/opt/backup/[BACKUP_FILE]
# 4. コンテナを起動する
#   docker-compose start

readonly BACKUP_DIR='/var/opt/backup'

function error() {
    echo "ERROR: $(basename $0): $@" 1>&2
}

function abort() {
    error $@
    exit 1
}

[ $# -eq 2 ] || abort "Usage: $0 [CONTAINER_NAME] [BACKUP_FILE]"
readonly CONTAINER_NAME=$1
readonly BACKUP_FILE=$2

docker run --rm --volumes-from ${CONTAINER_NAME} -v ${BACKUP_DIR}:/var/opt/backup busybox tar xf ${BACKUP_FILE}

exit 0
