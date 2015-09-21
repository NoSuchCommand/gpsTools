#!/bin/bash

SRCDIR="/var/satellite/mrepo"

WORKDIR="/tmp/mrepo-download-groups-$$"
mkdir -p "$WORKDIR"
if [ $? -ne 0 ]
then
	exit 1
fi
cd "$WORKDIR"
if [ $? -ne 0 ]
then
	exit 1
fi

for MREPO_CONF in /etc/mrepo.conf.d/*.conf
do
	DIST_NICK=$(basename "$MREPO_CONF" .conf)
	ARCH=$(grep -E '^ *arch *=' $MREPO_CONF | awk '{ print $NF}')
	awk -F= '$1 !~ /^#/ && $2 ~ /^ *http/' "$MREPO_CONF" | while read CHANNEL
	do
		NAME=$(echo $CHANNEL | tr -d ' ' | cut -d = -f1)
		URL=$(echo $CHANNEL | tr -d ' ' | cut -d = -f2 | \
			sed -e "s/\$arch/$ARCH/" -e 's/Packages$/repodata/')
		if [ -z "$NAME" -o -z "$URL" ]
		then
			continue
		fi

		for LFTP_CONF in /etc/lftp.conf.*
		do
			if [ ! -e "$LFTP_CONF" ]
			then
				break
			fi
			grep -E '^set ssl:' "$LFTP_CONF" > cmds
			echo "mget $URL/*-comps.xml" >> cmds

			lftp -f cmds &> /dev/null
			for COMPS in *-comps.xml
			do
				if [ -f "$COMPS" ]
				then
					mv -f "$COMPS" \
					"$SRCDIR/$DIST_NICK/${NAME}-comps.xml"
				fi
			done
			rm -f *-comps.xml cmds
		done
	done
done
cd /tmp
rm -rf "$WORKDIR"

