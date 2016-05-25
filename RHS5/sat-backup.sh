#!/bin/bash

BACKUP_DIR="/var/satellite/backup"
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


mylog "Arret du Red Hat Satellite..."
/usr/sbin/rhn-satellite stop
/usr/sbin/rhn-satellite status
mylog "Fini"

mylog "Backup base de donnees..."
rm -rf "${WORKING_BACKUP_DIR}"
mkdir -p "${WORKING_BACKUP_DIR}/db"
/usr/bin/db-control backup "${WORKING_BACKUP_DIR}/db"
mylog "Fini"

mylog "Verification de la sauvegarde de la base de donnees..."
/usr/bin/db-control verify "${WORKING_BACKUP_DIR}/db"
if [ $? -eq 0 ]
then
	mylog "Fini"
else
	mylog "ERREUR"
	ERROR=1
fi


mylog "Sauvegarde des repertoires du Satellite..."
# List of files/directories to backup from the chapter "3.1. Backing Up the
# Satellite Server" from the Red Hat Satellite User Guide
TO_BACKUP=""
for F in  \
		/root/sat-backup.sh \
		/var/lib/pgsql \
		/etc/sysconfig/rhn \
		/etc/rhn \
		/etc/dhcp \
		/etc/sudoers \
		/var/www/html/pub \
		"/var/satellite/redhat/[0-9]*" \
		/root/.gnupg \
		/root/ssl-build \
		/etc/dhcp.conf \
		/etc/httpd \
		/tftpboot \
		/var/lib/tftpboot \
		/var/lib/cobbler \
		/var/lib/rhn/kickstarts \
		/var/www/cobbler \
		/var/lib/nocpulse
do
	if [ -e "$F" ]
	then
		TO_BACKUP="${TO_BACKUP} $F"
	fi
done

tar zcf "${WORKING_BACKUP_DIR}/files.tgz" $TO_BACKUP
if [ $? -eq 0 ]
then
	mylog "Fini"
else
	mylog "ERREUR"
	ERROR=1
fi

mylog "Demarrage du Red Hat Network Satellite Server..."
/usr/sbin/rhn-satellite start
/usr/sbin/rhn-satellite status
mylog "Fini"

if [ $ERROR -eq 0 ]
then
	rm -rf "$PREVIOUS_BACKUP_DIR"
	mv "$CURRENT_BACKUP_DIR" "$PREVIOUS_BACKUP_DIR" &> /dev/null
	mv "$WORKING_BACKUP_DIR" "$CURRENT_BACKUP_DIR"
fi

