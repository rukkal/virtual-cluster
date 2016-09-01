# Virtual cluster
> A vagrant-based virtual cluster with slurm + shifter on top of Ubuntu Trusty


## How to use it
- create the virtual machines and provision them:
```shell
cd <project root folder> # i.e. where vagrant file is located
vagrant up
```
- start services in the server machine:
```shell
vagrant ssh server
sudo /etc/init.d/munge start
sudo /etc/init.d/slurm start
```
- start services in the controller machine:
```shell
vagrant ssh controller
sudo /etc/init.d/munge start
sudo /etc/init.d/shifter-imagegw start
sudo slurmctld -D
```

Now you are ready to go. You can use slurm + shifter to schedule containerized jobs in the cluster. For example:
```shell
vagrant ssh controller
shifterimg pull docker:debian:jessie
salloc -N 1 -t 10 --image=docker:debian:jessie
srun shifter cat /etc/debian_version
```
EXPECTED OUTPUT: 8.5 (eureka! we ran 'cat' in a debian container!)

See [shifter's wiki](https://github.com/nersc/shifter/wiki) and [slurm's website](http://slurm.schedmd.com) for more information.

## How the installation works
The list below provides an overview of the steps performed in the Vagrantfile. The described steps are performed inside each guest machine (controller + server). The directory "shared-folder" provided in this repository is mounted at /shared-folder inside the guest machines.
1. Modify /etc/hosts so that "controller" will know the address of "server" and vice versa.
2. Install various dependencies of slurm and shifter with APT.
3. Install and configure munge (install-munge.sh):
   1. Install munge with APT.
   2. Copy /shared-folder/installation/munge.key to /etc/munge and change owner and permissions. WARNING: munge.key is already provided in this repository. However, for any more serious use than this insecure toy virtual cluster a new munge.key should be generated with /usr/sbin/create-munge-key.
4. Install and configure slurm (install-slurm.sh):
   1. Download, build and install slurm from source.
   2. Set up a state save location for slurm in /var/lib/slurm.
   3. Set up startup scripts in /etc/init.d/slurm.
   4. Create a symlink /etc/slurm.conf to /shared-folder/installation/slurm.conf.
5. Install and configure shifter (install-shifter.sh):
   1. Build and install udiRoot in /opt/shifter/udiRoot. The most important things that get installed are the shifter and shifterimg executables as well as the plugin for slurm. The shifter and shifterimg executables provide the user interface of shifter.
   2. Copy /shared-folder/installation/udiRoot.conf to /etc/shifter/udiRoot.conf. The file udiRoot.conf provides most of the configuration details of shifter.
   3. Configure slurm to use the shifter plugin. This is achieved through the configuration file /etc/plugstack.conf.
   4. Install image gateway:
      1. Set up a python virtual environment in /opt/shifter/imagegw where the image gateway will be executed.
      2. Create a symlink /etc/shifter/imagemanager.json to /shared-folder/installation/imagemanager.json. The file imagemanager.json provides configuration details of the image gateway.
      3. Set up startup scripts in /etc/init.d.

## Details
- Tested on Ubuntu 16.04 with Vagrant 1.8.1 and Virtualbox 5.0.18
- Cluster configuration: 1 controller node + 1 server node


## Troubleshooting
###Provisioning
It might occur that the provision partially goes wrong because of short unavailabilities of the APT service. In such cases the easiest solution is running the provision again:
```shell
vagrant reload --provision <machine name>
```
###Shifter image pull
Shifter is still an early development product and as such has still many bugs. When large images are pulled from docker the shifter program might start displaying "PENDING" as status and the image gateway enters an infinite pull-expand-mksquashfs loop. A possible workaround is killing the image gateway as soon as the squashfs image is created. Then the respective document in MongoDB needs to be manually modified:
```shell
mongo
use Shifter
db.images.find()
```
MongoDB will display a list of documents. Find the document corresponding to the image that was being pulled (status field: "PENDING") and remove it using its _id field:
```shell
db.images.remove("_id" : ObjectId("<the ID>"))
```
Then insert a new document as shown below. Just adapt the fields so that they match the actual image and shifter environment.
```shell
db.images.insert({
   "ENTRY" : null,
   "ENV" : [  "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" ],
   "arch" : "amd64",
   "expiration" : 1476695966.629979,
   "format" : "ext4",
   "groupAcl" : [ ],
   "id" : "d3c7b4a9f6b50f8263ee3a3efe5272939b9e75c5ce8e56461a7b35225d03b5ef",
   "itype" : "docker",
   "last_pull" : 1468916608.391633,
   "location" : "",
   "os" : "linux",
   "ostcount" : "0",
   "pulltag" : "rukkal/patachakka:latest",
   "remotetype" : "dockerv2",
   "replication" : "1",
   "status" : "READY",
   "system" : "mycluster",
   "tag" : [ "rukkal/patachakka:latest" ],
   "userAcl" : [ ] })
```
