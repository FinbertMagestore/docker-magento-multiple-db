#!/usr/bin/env bash

source bin/common.sh

# init file data/init/database.sql dynamic by magento version
function create_file_init_database_mysql() {
    local init_database_file='data/init/database.sql'
    rm -f ${init_database_file}
    touch ${init_database_file}
    cp "data/backups/database.sql" ${init_database_file}
    for i in "${MAGENTO_VERSION_ARRAY[@]}"
    do
        local port_service_docker=`get_port_service_docker "${i}"`
        local init_database_string='CREATE DATABASE IF NOT EXISTS magento'${port_service_docker}';'
        echo ${init_database_string} >> ${init_database_file}
    done
}

function validate_sql_files_init_folder() {
    mkdir -p data/backups
    find data/init/ -type f  ! -name "*.sql" -delete
    local has_backup_sql=0
    for file_path in data/init/*.sql ; do
        if [[ ! ${file_path} == *database.sql ]]; then
            local file_name=${file_path##*/}
            local file_name=${file_name%.*}
            if [[ ! ${MAGENTO_VERSIONES} == *${file_name}* ]]; then
                mv ${file_path} 'data/backups/'
                has_backup_sql=1
            fi
        fi
    done
#    if [[ ${has_backup_sql} = 1 ]]; then
#        remove_backups_sql
#    fi
}

#function remove_backups_sql() {
#    echo "Backups folder is files sql in folder init but it isn't belong to version Magento in file .env"
#    print_color 'Are you want remove backups folder? y/n?' 'red'
#    read flag
#    if [[ ${flag} = [Yy]* ]]; then
#        rm -rf data/backups
#        echo 'Removed backups folder.'
#    fi
#}

function copy_sql_from_backup_to_init() {
    rm -rf data/init
    mkdir -p data/init
    find data/backups/ -type f  ! -name "*.sql" -delete
    for file_path in data/backups/*.sql ; do
        if [[ ! ${file_path} == *database.sql ]]; then
            local file_name=${file_path##*/}
            local file_name=${file_name%.*}
            if [[ ${MAGENTO_VERSIONES} == *${file_name}* ]]; then
                cp ${file_path} 'data/init/'
            fi
        fi
    done
}

function main() {
    copy_sql_from_backup_to_init
    create_file_init_database_mysql
#    validate_sql_files_init_folder
    echo 'Please place some file sql at folder data/init.'
}

main