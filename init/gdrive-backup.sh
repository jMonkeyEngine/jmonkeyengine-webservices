#!/bin/bash
set -e
source /config.sh

if [ "$GDRIVE_BACKUP_PASSWORD" = "" \
 -o "$GDRIVE_BACKUP_FOLDER_ID" = "" \
 -o "$GDRIVE_BACKUP_TOKEN" = "" \
 -o "$GDRIVE_BACKUP_CLIENT_ID" = "" \
 -o "$GDRIVE_BACKUP_CLIENT_SECRET" = "" \
];
then
    echo "GDRIVE backup disabled."
    exit 0
fi

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

# GDRIVE
mkdir -p ~/.config/rclone/
echo "[gdrive-backup]
type = drive
client_id = ${GDRIVE_BACKUP_CLIENT_ID}
client_secret = ${GDRIVE_BACKUP_CLIENT_SECRET}
scope = drive.file
root_folder_id = ${GDRIVE_BACKUP_FOLDER_ID}
token = ${GDRIVE_BACKUP_TOKEN}
team_drive = 

[gdrive-backup-enc]
type = crypt
remote = gdrive-backup:/enc
password = `rclone obscure ${GDRIVE_BACKUP_PASSWORD}`" >  "$HOME/.config/rclone/rclone.conf"



#######
rclone delete gdrive-backup-enc:/jmonkeyengine/backup/srv
rclone  -P sync /srv gdrive-backup-enc:/jmonkeyengine/backup/srv
rclone delete gdrive-backup-enc:/jmonkeyengine/backup/backups
rclone  -P sync /backups gdrive-backup-enc:/jmonkeyengine/backup/backups
#######
/cleanup.sh
