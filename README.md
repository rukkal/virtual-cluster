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

## Details
- Tested on Ubuntu 16.04 with Vagrant 1.8.1 and Virtualbox 5.0.18
- Cluster configuration: 1 controller node + 1 server node


## Troubleshooting
It occurred that the provision partially went wrong because of a short unavailability of the APT service. In such cases the solution was running the provision again:
```shell
vagrant reload --provision <machine name>
```
