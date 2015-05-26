# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

require 'yaml'

# Defaults values
vars=YAML.load_file('./files/default_vars.yml')
vars.merge!(YAML.load_file('external_vars.yml'))

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
    
    config.vm.network "private_network", ip: "#{vars['vm_private_ip']}"
    config.vm.network "forwarded_port", guest: 80, host: 8080
    config.vm.network "forwarded_port", guest: 6080, host: 6080
    
    config.vm.provider :virtualbox do |vb|
        vb.memory = vars['vm_memory']
        vb.cpus = vars['vm_cpus']
    end
       
    if vars['trove']
     config.vm.provision :shell, path: "files/bootstrap.sh", args: "/vagrant/files vagrant"
    else
     config.vm.provision :shell, path: "files/bootstrap.sh", args: "/vagrant/files vagrant #{vars['trove_db_name']}"
    end
end
