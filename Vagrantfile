# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

require 'yaml'

# Defaults values
vars=YAML.load_file('./files/default_vars.yml')
if (not File.file?('config.yml'))
	File.open("config.yml", 'w') do |file|
		File.open('./files/default_vars.yml', "r").each_line do |line|
			file.write '#' + line
		end
		file.write 'state: running'
	end
end
vars.merge!(YAML.load_file('config.yml')) 

if vars['trove'] and (not vars['heat'] or not vars['swift']) then
 fail 'trove must be enabled with heat and swift'
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
 
    if Vagrant.has_plugin?("vagrant-proxyconf")
      config.proxy.http    = ENV['http_proxy'] if  ENV['http_proxy']!=nil
      config.proxy.https    = ENV['https_proxy'] if  ENV['https_proxy']!=nil
      config.proxy.no_proxy = ENV['no_proxy'] if ENV['no_proxy']!=nil
    end
    
    # if you have a vagrant-cachier plugin, use it for apt caches
    if Vagrant.has_plugin?("vagrant-cachier")
      config.cache.scope = :box
    end
    
    config.vm.box = "ubuntu/trusty#{vars['vm_archbits']}"

    # Ubuntu has a "bug" (https://github.com/mitchellh/vagrant/issues/1673)
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"  

    config.vm.hostname = 'devstack'
    
	# eth1, this will be the endpoint
    config.vm.network "private_network", ip: "#{vars['vm_host_ip']}"
    # eth2, this will be the OpenStack "public" network, use DevStack default
    config.vm.network :private_network, ip: "172.24.4.225", :netmask => "255.255.255.0", :auto_config => false
    config.vm.network "forwarded_port", guest: 80, host: 8080
	config.vm.network "forwarded_port", guest: 5000, host: 5000
	config.vm.network "forwarded_port", guest: vars['vnc_port'], host: vars['vnc_port']
    
    config.vm.provider :virtualbox do |vb|
        vb.memory = vars['vm_memory']
        vb.cpus = vars['vm_cpus']
		vb.customize ["modifyvm", :id, "--ioapic", "on"]
        # eth2 must be in promiscuous mode for floating IPs to be accessible
        vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
    end
       
    if vars['trove']
     config.vm.provision :shell, path: "files/bootstrap.sh", args: "/vagrant/files vagrant #{vars['trove_db_name']}"
    else
     config.vm.provision :shell, path: "files/bootstrap.sh", args: "/vagrant/files vagrant"
    end
end
