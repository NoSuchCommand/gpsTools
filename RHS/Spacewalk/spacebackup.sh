#!/bin/bash

BACKUP_DIR="/var/satellite/backup"
LOG_FILE="${BACKUP_DIR}/log.$(date +%u)"
CURRENT_BACKUP_DIR="${BACKUP_DIR}/current"
PREVIOUS_BACKUP_DIR="${BACKUP_DIR}/previous"
WORKING_BACKUP_DIR="${BACKUP_DIR}/working"
ERROR=0
SERVICECMD=service

export PATH=/bin:/sbin:/usr/bin:/usr/sbin

function mylog()
{
	echo "======== $(date +%H:%M:%S) - $@"
}

function service7() {
	local service=$1
	shift
	systemctl $1 $service
}

osver=$(sed -r 's#^[a-zA-Z ]+([0-9]).*#\1#' /etc/redhat-release)
[[ "$osver" =~ ^[0-9]$ ]] || {
	mylog "ERREUR: Plateforme non supportee"
	exit 1
}
((osver > 6)) && {
	SERVICECMD=service7
}

mkdir -p "$BACKUP_DIR"
exec &> "${LOG_FILE}"

mylog "Arret de Spacewalk..."
/usr/sbin/spacewalk-service stop
/usr/sbin/spacewalk-service status
mylog "Fini"

mylog "Backup base de donnees..."
rm -rf "${WORKING_BACKUP_DIR}"
mkdir -p "${WORKING_BACKUP_DIR}/db"
mylog "--> Demarrage de la base"
$SERVICECMD postgresql start
sleep 5
su - postgres -c 'pg_dumpall' > "${WORKING_BACKUP_DIR}/db/backup.sql"
mylog "--> Arret de la base"
$SERVICECMD postgresql stop
mylog "Fini"

mylog "Sauvegarde des fichiers de Spacewalk..."
# List of files/directories to backup from the Spacewalk documentation
# https://fedorahosted.org/spacewalk/wiki/SpacewalkBackup
TO_BACKUP=""
for F in  \
		/var/satellite/install-data \
		/etc/mrepo.conf.d \
		/etc/mrepo.conf \
		/etc/lftp.conf.* \
		/var/lib/pgsql \
		/etc/sysconfig/rhn \
		/etc/rhn \
		/etc/dhcp \
		/etc/sudoers \
		/var/www/html/pub \
		"/var/satellite/redhat/[0-9]*" \
		/root/.gnupg \
		/root/ssl-build \
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
/usr/sbin/spacewalk-service start
/usr/sbin/spacewalk-service status
mylog "Fini"

if [ $ERROR -eq 0 ]
then
	rm -rf "$PREVIOUS_BACKUP_DIR"
	mv "$CURRENT_BACKUP_DIR" "$PREVIOUS_BACKUP_DIR" &> /dev/null
	mv "$WORKING_BACKUP_DIR" "$CURRENT_BACKUP_DIR"
fi

