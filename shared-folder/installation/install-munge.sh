#!/bin/bash

apt-get install munge
#WARNING: for any more serious use than this insecure toy virtual cluster a new munge.key file
#should be generated with /usr/sbin/create-munge-key
cp /shared-folder/installation/munge.key /etc/munge
chown munge /etc/munge/munge.key
chmod 400 /etc/munge/munge.key
chmod 755 /var/log
