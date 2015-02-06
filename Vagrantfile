# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "centos64"
  config.vm.box_check_update = false
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = "box"
    config.cache.synced_folder_opts = {
      type: "nfs",
      mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
    }
  end
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end
  config.vm.synced_folder '.', '/vagrant', nfs: true
  config.vm.provision "shell", path: "bootstrap.sh"

  config.vm.define "master" do |master|
    master.vm.hostname = "master"
    master.vm.network "private_network", ip: "10.0.0.11"
    master.vm.provision "shell", path: "install-salt-master.sh"
  end
  config.vm.define "syndic1" do |syndic1|
    syndic1.vm.hostname = "syndic1"
    syndic1.vm.network "private_network", ip: "10.0.0.12"
    syndic1.vm.provision "shell", path: "install-salt-syndic.sh"
  end
  config.vm.define "syndic2" do |syndic2|
    syndic2.vm.hostname = "syndic2"
    syndic2.vm.network "private_network", ip: "10.0.0.13"
    syndic2.vm.provision "shell", path: "install-salt-syndic.sh"
  end
end
