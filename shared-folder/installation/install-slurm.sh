#!/bin/bash

echo "installing slurm"

cd $(mktemp -d)
wget http://www.schedmd.com/download/archive/slurm-16.05.2.tar.bz2
tar xvf slurm-16.05.2.tar.bz2
cd slurm-16.05.2
./configure --prefix=/usr --sysconfdir=/etc
make
make install

STATE_SAVE_LOCATION=/var/lib/slurm
mkdir -p $STATE_SAVE_LOCATION
chown vagrant $STATE_SAVE_LOCATION
chmod 755 $STATE_SAVE_LOCATION

cp /shared-folder/installation/init.d.slurm /etc/init.d/slurm
ln -s /shared-folder/installation/slurm.conf /etc/slurm.conf
