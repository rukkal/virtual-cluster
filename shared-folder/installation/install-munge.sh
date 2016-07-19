#!/bin/bash

apt-get install munge
cp /shared-folder/installation/munge.key /etc/munge
chown munge /etc/munge/munge.key
chmod 755 /var/log
