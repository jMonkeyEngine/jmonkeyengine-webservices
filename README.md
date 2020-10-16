# jMonkeyEngine Services configuration

Replicable configurations for our services.

This README is here for people to migrate the server in the future or run a clone for testing purposes.

## Requirement
1.  A linux workstation with docker-machine
2. A target Ubuntu 20.04 x86_64 server (Newer ubuntu versions might work aswell).
3. Two S3 compatible object storage buckets with glacier support (for backups).

## Disks layout
This is not configured by the script, so it has to be done manually before running install.sh.

This is just my current configuration, you don't need to respect this layout exactly. 

Actually, you can just ignore it, and install the server on a single disk. As long as the paths are resolved it will work.

- Generic storage: `/`
    - Non incremental backups path: `/backups` 
- Replicated storage: `/srv`
- Swap: `/swapfile1`

### Disk setup example
```console
$ mkdir -p /srv
$ mkdir -p /backups
$ lsblk
# Find the volume
$ mkfs.ext4 /dev/sda
$ lsblk -f
# Get UUID
$ nano /etc/fstab
# Add UUID=DISKUUID /srv ext4 defaults 0 0
$ mount -a
$ mount | grep /srv # Check if fs is mounted
# Swap
$ fallocate -l 1G /swapfile1
$ chmod 600 /swapfile1
$ mkswap /swapfile1
$ swapon /swapfile1
$ echo '/swapfile1 none swap sw 0 0' | tee -a /etc/fstab
$ cat /etc/fstab # Check if swap is added
$ free -h # Check if swap is loaded

```


## Backup Reference
This is a reference to know what is backuped and how, the scripts take care of setting up the backup policy.

- Always full backup path: `/backups`
- Incremental backup path: `/srv`
    - Exclusions
        - `/srv/mysql_data`
        - `/srv/hub`


## Config
1. Copy config.template.sh into config.sh
2. Edit config.sh

## Install 
Running ./install.sh generates or updates the server.

### New
`INSTALL="all" HOST_SETUP=1 ./install.sh`

### From backup
`INSTALL="all" HOST_SETUP=1 RESTORE=1 ./install.sh`

### Install without certificates
`INSTALL="all" SKIP_CERTS=1  ./install.sh`

### Regenerate certificates
`INSTALL="nginx_gateway"  ./install.sh`


### Options list
- HOST_SETUP="1" : Install and configure all the required supporting software on the host, setup backup policies. mail alerts, updates etc. DEFAULT VALUE: ""
- NO_RESTART="1" : Do not reboot macking after HOST_SETUP is complete. DEFAULT VALUE: ""
- RESTORE="1" : Restore the last backup. DEFAULT VALUE: ""
- SKIP_CERTS="1" : Use the placeholder certificates instead of generating valid certificates as part of the installation process. This is useful when replicating the server locally or on an host to which the domains are not pointing yet. It is possible to regenerate the certificate later by reinstalling the nginx_gateway. DEFAULT VALUE: ""
- INSTALL="service" : Install reinstall or update one of the services configured in init/installers. DEFAULT VALUE: "all" to install all.



## Add a container to the health check
1. Configure the container to check its health (see docker documentation, --health-cmd)
2. Add the container name to /init/installers/healthcollector/healthcollector.data
3. Reinstall healthcollector-inst

## Folder structure

- init/ contains all the management scripts. 
- config/ contains all the configurations
- www/ contains static files

## Trigger a backup of the server
This is done automatically by a cronjob.
If needed you can trigger a backup manually with:
- `./backup-remote.sh` : For a full backup
- `./backup-remote.sh incremental` : For an incremental backup

## Cheatsheet
### How to grant yourself the admin role  in discourse
1. cd  /srv/hub/
2. ./launcher enter app
3. rake admin:create
4. Insert your email
5. Grant the privileges
6. Done!


### Change CDN in hub
1. cd  /srv/hub
2. Change in containers/app.yml
3. ./launcher enter app
4.  rake posts:rebake

### Replace a word sitewide on hub
1. cd /srv/hub
2. ./launcher enter app
3. rake posts:remap["original","replacement"]

### Regenerate hub search index
1. cd /srv/hub
2. ./launcher enter app
3. rake search:reindex

### Cleanup hub database 
1. cd /srv/hub
2. ./launcher enter app
3. su - postgres
4. psql discourse
5. VACUUM FULL;

