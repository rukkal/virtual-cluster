#!/bin/bash

echo "installing slurm"

cd $(mktemp -d)
wget https://github.com/SchedMD/slurm/archive/slurm-16-05-10-2.tar.gz
tar xvf slurm-16-05-10-2.tar.gz
cd slurm-slurm-16-05-10-2
./configure --prefix=/usr --sysconfdir=/etc
make
make install

STATE_SAVE_LOCATION=/var/lib/slurm
mkdir -p $STATE_SAVE_LOCATION
chown vagrant $STATE_SAVE_LOCATION
chmod 755 $STATE_SAVE_LOCATION

cp /shared-folder/installation/init.d.slurm /etc/init.d/slurm
ln -s /shared-folder/installation/slurm.conf /etc/slurm.conf
