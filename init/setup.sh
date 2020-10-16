#!/bin/bash
set -e
source /config.sh

export DEBIAN_FRONTEND=noninteractive 

# Upgrade and install bare minimum
apt-get update -y
apt-get upgrade -o Dpkg::Options::="--force-confold" -y
apt-get dist-upgrade -o Dpkg::Options::="--force-confold"  -y
apt-get install -y  \
  sudo  \
  nano \
  unattended-upgrades \
  apache2-utils \
  msmtp \
  msmtp-mta \
  bsd-mailx \
  sshpass \
  run-one \
  psmisc \
  git

# Configure SMTP
echo "defaults
auth             on   
tls              on 
logfile          /var/log/msmtp.log
tls_trust_file /etc/ssl/certs/ca-certificates.crt

account        maildf
host ${ROBOT_SMTP_HOST}
port ${ROBOT_SMTP_PORT}
user ${ROBOT_EMAIL_USERNAME}
from ${ROBOT_EMAIL}
password ${ROBOT_EMAIL_PASSWORD}

account default : maildf" > /etc/msmtprc
touch /var/log/msmtp.log
chmod 666 /var/log/msmtp.log

# Auto updates
dpkg-reconfigure unattended-upgrades

echo "APT::Periodic::Update-Package-Lists \"1\";
APT::Periodic::Unattended-Upgrade \"1\";
APT::Periodic::Download-Upgradeable-Packages \"1\";
APT::Periodic::Unattended-Upgrade \"1\";
APT::Periodic::AutocleanInterval \"10\";" > /etc/apt/apt.conf.d/20auto-upgrades

echo "Unattended-Upgrade::Allowed-Origins {
     \"\${distro_id}:\${distro_codename}\";
	\"\${distro_id}:\${distro_codename}-security\";	
};
Unattended-Upgrade::DevRelease \"false\";
//Unattended-Upgrade::AutoFixInterruptedDpkg \"false\";
Unattended-Upgrade::MinimalSteps \"true\";
Unattended-Upgrade::InstallOnShutdown \"false\";
Unattended-Upgrade::Mail \"${TEAM_EMAIL_DEST}\";
Unattended-Upgrade::MailOnlyOnError \"false\";
Unattended-Upgrade::Remove-Unused-Kernel-Packages \"false\";
Unattended-Upgrade::Remove-Unused-Dependencies \"false\";
Unattended-Upgrade::Automatic-Reboot \"false\";
Unattended-Upgrade::Automatic-Reboot-Time \"02:00\";
Acquire::http::Dl-Limit \"500\";
Unattended-Upgrade::SyslogEnable \"true\";
Unattended-Upgrade::SyslogFacility \"daemon\";
Unattended-Upgrade::OnlyOnACPower \"false\";
Unattended-Upgrade::Skip-Updates-On-Metered-Connections \"false\";" > /etc/apt/apt.conf.d/50unattended-upgrades

# Alert on login
if [ "`cat ~root/.bashrc | grep ALERT SSH`" = "" ];
then
echo "
  echo \"ALERT SSH Access to \$(cat /etc/hostname) from \$(who)\" | mailx -s \"ALERT SSH Access: $(cat /etc/hostname)\" ${TEAM_EMAIL_DEST}&
  ">>~root/.bashrc
fi

# Basic autostart script
if [ ! -f /etc/rc.local ];
then
  echo "#!/bin/bash
exit 0">/etc/rc.local
fi

# More configs
if [ "`cat /etc/rc.local | grep transparent_hugepage`" = "" ];
then
  sed -i -e '$i \echo never > /sys/kernel/mm/transparent_hugepage/enabled\n' /etc/rc.local
fi


if [ "`cat /etc/rc.local | grep overcommit_memory`" = "" ];
then
  sed -i -e '$i \sysctl vm.overcommit_memory=1\n' /etc/rc.local
fi


if [ "`cat /etc/rc.local | grep timedatectl set-timezone UTC`" = "" ];
then
  sed -i -e '$i \timedatectl set-timezone UTC\n' /etc/rc.local
fi



# Backups
mkdir -p /backups

## Install duplicity
cdir="$PWD"
cd /tmp
apt install -y python3-boto python3-pip haveged gettext librsync-dev
wget https://code.launchpad.net/duplicity/0.8-series/0.8.12/+download/duplicity-0.8.12.1612.tar.gz
tar xaf duplicity-0.8.*.tar.gz
rm duplicity-0.8.*.tar.gz
cd duplicity-0.8.*
pip3 install -r requirements.txt
python3 setup.py install
cd "$cdir"

## Configure backup update cleanup cron
(crontab -l ; echo "00 1 1 * * (/backup.sh&&/installers/updater.sh&&/cleanup.sh) >> /var/log/robot.log") | sort - | uniq - | crontab -
(crontab -l ; echo "00 7 * * 7 (/backup.sh incremental) >> /var/log/robot.log") | sort - | uniq - | crontab -
