#Define the list of machines
slurm_cluster = {
    :controller => {
        :hostname => "controller",
        :ipaddress => "10.10.10.3"
    },
    :server => {
        :hostname => "server",
        :ipaddress => "10.10.10.4"
    }
}

$provision_script = <<SCRIPT
echo "10.10.10.3    controller" >> /etc/hosts
echo "10.10.10.4    server" >> /etc/hosts
#provision dependencies
sudo add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ precise universe multiverse"
sudo apt-get update -qq
#note: running the following apt-get commands as one liner used to generate errors messages such as
#'Failed to fetch http://.../blahblah.deb  403  Forbidden [IP: 91.189.88.152 80]'
sudo apt-get install -qq unzip
sudo apt-get install -qq python-pip
sudo apt-get install -qq libjson-c2
sudo apt-get install -qq libjson-c-dev
sudo apt-get install -qq libmunge2
sudo apt-get install -qq libmunge-dev
sudo apt-get install -qq libcurl4-openssl-dev
sudo apt-get install -qq autoconf
sudo apt-get install -qq automake
sudo apt-get install -qq libtool
sudo apt-get install -qq curl
sudo apt-get install -qq make
sudo apt-get install -qq xfsprogs
sudo apt-get install -qq squashfs-tools
sudo apt-get install -qq mongodb
sudo apt-get install -qq redis-server
#install shifter system
/shared-folder/installation/install-munge.sh
/shared-folder/installation/install-slurm.sh
/shared-folder/installation/install-shifter.sh
SCRIPT

Vagrant.configure("2") do |global_config|
    slurm_cluster.each_pair do |name, options|
        global_config.vm.define name do |config|
            config.vm.box = "ubuntu/trusty64"
            config.vm.hostname = "#{name}"
            config.vm.network :private_network, ip: options[:ipaddress]
            config.vm.synced_folder "shared-folder", "/shared-folder"

            config.vm.provider :virtualbox do |v|
                v.customize ["modifyvm", :id, "--memory", "2048"]
            end

            config.vm.provision :shell,
                :inline => $provision_script
        end
    end
end

