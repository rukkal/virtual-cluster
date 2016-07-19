#!/bin/bash

echo "installing shifter"

SHIFTER_SYSCONFDIR=/etc/shifter

cd $(mktemp -d) 
wget https://github.com/lichinka/shifter/archive/master.zip
unzip master.zip
cd shifter-master

# udiroot
####################
UDIROOT_PREFIX=/opt/shifter/udiRoot

#the folowing command must be cp (ln -s would break the build because scripts expect asm to be a directory)
cp -rp /usr/include/asm-generic /usr/include/asm 
mkdir -p $UDIROOT_PREFIX

./autogen.sh
#export CFLAGS='-O0 -g'   # use this if you need to debug the code 
#export CXXFLAGS='-O0 -g' # use this if you need to debug the code 
./configure --prefix=$UDIROOT_PREFIX --sysconfdir=$SHIFTER_SYSCONFDIR --with-json-c --with-libcurl --with-munge --with-slurm=/usr
make CFLAGS="-D__ARCH_WANT_SYSCALL_NO_AT -D__ARCH_WANT_SYSCALL_OFF_T -D__ARCH_WANT_SYSCALL_DEPRECATED"
make install

ln -s $UDIROOT_PREFIX/bin/shifter /usr/bin/shifter
ln -s $UDIROOT_PREFIX/bin/shifterimg /usr/bin/shifterimg
mkdir -p /usr/libexec/shifter
ln -s /opt/shifter/udiRoot/libexec/shifter/mount /usr/libexec/shifter/mount 

mkdir -p $SHIFTER_SYSCONFDIR
cp /shared-folder/installation/udiRoot.conf $SHIFTER_SYSCONFDIR/udiRoot.conf

# slurm (must be configured to use shifter plugin)
####################
SLURM_SYSCONFDIR=/etc
echo "required $UDIROOT_PREFIX/lib/shifter/shifter_slurm.so shifter_config=/etc/shifter/udiRoot.conf" >> $SLURM_SYSCONFDIR/plugstack.conf

# imagegw
####################
IMAGEGW_PATH=/opt/shifter/imagegw
IMAGES_CACHE_EXPAND_PATH=/var/opt/shifter/images
IMAGES_PATH=/shifter/vagrant/cluster/shifter-images
PYTHON_VENV="python-virtualenv"

mkdir -p $IMAGEGW_PATH
mkdir -p $IMAGES_CACHE_EXPAND_PATH
mkdir -p $IMAGES_PATH
rsync -av --progress ./imagegw/ $IMAGEGW_PATH

cd $IMAGEGW_PATH
pip install virtualenv
virtualenv ${PYTHON_VENV} --python=/usr/bin/python2.7
source ${PYTHON_VENV}/bin/activate
pip install -r requirements.txt

mkdir -p /etc/shifter && ln -s /shared-folder/installation/imagemanager.json $SHIFTER_SYSCONFDIR/imagemanager.json
ln -s /shared-folder/installation/start-imagegw.sh ${IMAGEGW_PATH}/start-imagegw.sh
ln -s /shared-folder/installation/init.d.shifter-imagegw /etc/init.d/shifter-imagegw
