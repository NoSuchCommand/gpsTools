#!/bin/bash
#
# Backup the RHEV-M database and configuration files.
# For more details see the "Backups" chapter of the "Red Hat Enterprise
# Virtualization - Administration Guide" at
# https://access.redhat.com/site/documentation/en-US/Red_Hat_Enterprise_Virtualization/3.3/html/Administration_Guide/index.html
# and also https://access.redhat.com/site/solutions/797463

BACKUP_DIR="/var/ftp/rh/backups"
LOG_FILE="${BACKUP_DIR}/log.$(date +%u)"
CURRENT_BACKUP_DIR="${BACKUP_DIR}/current"
PREVIOUS_BACKUP_DIR="${BACKUP_DIR}/previous"
WORKING_BACKUP_DIR="${BACKUP_DIR}/working"
ERROR=0

function mylog()
{
	echo "======== $(date +%H:%M:%S) - $@"
}


exec &> "${LOG_FILE}"


# Backup directory setup
rm -rf "${WORKING_BACKUP_DIR}"


#
# Database backup
#
mylog "Database backup: $DB..."
mkdir -p "${WORKING_BACKUP_DIR}/db"
/usr/bin/engine-backup --mode=backup --scope=all \
		       --file="${WORKING_BACKUP_DIR}/db/backup.tar.bz2" \
		       --log=/tmp/log.out.$$
cat /tmp/log.out.$$ 2> /dev/null
rm -f /tmp/log.out.$$
mylog "Done"


#
# Configuration files backup
#
mylog "Configuration files backup..."
# List of files/directories to backup from the chapter
# "18.3. Backing Up Manager Configuration Files"
# of the "Red Hat Enterprise Virtualization - Administration Guide"
TO_BACKUP=""
for F in  \
    /etc/ovirt-engine \
    /etc/sysconfig/ovirt-engine \
    /etc/yum/pluginconf.d \
    /etc/pki/ovirt-engine \
    /usr/share/jasperreports-server-pro/buildomatic \
    /usr/share/ovirt-engine-reports/buildomatic \
    /usr/share/ovirt-engine/conf \
    /usr/share/ovirt-engine/dbscripts \
    /usr/share/ovirt-engine-reports/reports/users \
    /usr/share/ovirt-engine-reports/default_master.properties \
    /var/lib/ovirt-engine/backups \
    /var/lib/ovirt-engine/deployments \
    /usr/share/ovirt-engine-reports \
    /var/log/ovirt-engine \
    /root
do
    if [ -e "$F" ]
    then
        TO_BACKUP="${TO_BACKUP} $F"
    fi
done

tar zcf "${WORKING_BACKUP_DIR}/files.tgz" $TO_BACKUP
if [ $? -eq 0 ]
then
	mylog "Done"
else
	mylog "ERROR"
	ERROR=1
fi

if [ $ERROR -eq 0 ]
then
    rm -rf "$PREVIOUS_BACKUP_DIR"
    mv "$CURRENT_BACKUP_DIR" "$PREVIOUS_BACKUP_DIR" &> /dev/null
    mv "$WORKING_BACKUP_DIR" "$CURRENT_BACKUP_DIR"
fi

