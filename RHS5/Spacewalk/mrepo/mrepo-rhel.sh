#!/bin/bash

if [ -f /etc/lftp.conf.rhel ]
then
    mv /etc/lftp.conf /tmp &> /dev/null
    rm -f /etc/lftp.conf
    ln -s /etc/lftp.conf.rhel /etc/lftp.conf
fi

/usr/bin/mrepo -q -ug redhat-6
/usr/bin/mrepo -q -ug redhat-7
