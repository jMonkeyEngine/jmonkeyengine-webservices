#!/bin/bash
set -e
source /config.sh

/cleanup.sh


# Prepare backup for the hub
rm  /backups/hub/default/robot_backup-*.gz || true
docker exec -w /var/www/discourse -i app bash -c "echo 'BackupRestore::Backuper.new(Discourse.system_user.id, with_uploads: false, filename: \"robot_backup\").run' | rails c"
outPath="`ls /backups/hub/default/robot_backup-*.gz`"
if [ "$outPath" != "" -a -f "$outPath" ];
then
    echo "Hub backup saved in $outPath"
else
    echo "Hub backup FAILED!"
fi

# Prepare backup for mysql
docker exec mysql sh -c "exec mysqldump  --flush-privileges --all-databases -uroot -p\"${MYSQL_ROOT_PASSWORD}\"" >  /backups/mysql.sql
if [ ! -f "/backups/mysql.sql" ];
then
    echo "Mysql backup failed"
else
    echo "Mysql backup saved in /backup/mysql.sql"
fi

/cleanup.sh

# BACKUP !
sync

export SOURCE1="/srv"
export SOURCE2="/backups"
export KEEP_BACKUP_TIME1="4M"
export KEEP_BACKUP_TIME2="2M"

# backup
echo "Perform backup"


type="full"
if [ "$1" = "incremental" ];
then
    type="incr"
fi

echo "Backup type $type"


echo "Removing expired backups of $SOURCE1 "
#/usr/local/bin/duplicity remove-older-than ${KEEP_BACKUP_TIME1} ${AWS_BUCKET1} --force

echo "Creating backup for $SOURCE1 of type $type"
/usr/local/bin/duplicity $type \
--no-encryption \
--asynchronous-upload \
--s3-use-glacier \
--exclude  ${SOURCE1}/mysql_data \
--exclude  ${SOURCE1}/hub \
${SOURCE1}/ ${AWS_BUCKET1}


echo "Removing expired backups for $SOURCE2"
/usr/local/bin/duplicity remove-older-than ${KEEP_BACKUP_TIME2} ${AWS_BUCKET2} --force
echo "Creating backup of $SOURCE2 of type full"
/usr/local/bin/duplicity full \
--no-encryption \
--asynchronous-upload \
--s3-use-glacier \
${SOURCE2}/ ${AWS_BUCKET2}


/cleanup.sh
