#!/bin/bash

if [ -f /etc/lftp.conf.jboss ]
then
    mv /etc/lftp.conf /tmp &> /dev/null
    rm -f /etc/lftp.conf
    ln -s /etc/lftp.conf.jboss /etc/lftp.conf
fi

/usr/bin/mrepo -q -ug jboss-6
