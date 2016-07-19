#!/bin/bash

echo "installing slurm"

cd $(mktemp -d)
wget http://www.schedmd.com/download/latest/slurm-16.05.2.tar.bz2
tar xvf slurm-16.05.2.tar.bz2
cd slurm-16.05.2
./configure --prefix=/usr --sysconfdir=/etc
make
make install

cp /shared-folder/installation/init.d.slurm /etc/init.d/slurm
ln -s /shared-folder/installation/slurm.conf /etc/slurm.conf
