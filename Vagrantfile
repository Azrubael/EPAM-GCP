# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
  
  ### ----- tfbuntu vm -----
  config.vm.define "tfbuntu" do |tfbuntu|
    tfbuntu.vm.box = "ubuntu/focal64"
    tfbuntu.vm.hostname = "tfbuntu"
    tfbuntu.vm.network "private_network", ip: "192.168.56.12"
    tfbuntu.vm.synced_folder ".", "/vagrant", disabled: false
    tfbuntu.vm.provider "virtualbox" do |ubuntu20|
      ubuntu20.name = "tfbuntu"
      ubuntu20.memory = "1600"
      ubuntu20.cpus = 2
      ubuntu20.customize ["modifyvm", :id, "--vram", "16"]
    end

    tfbuntu.vm.provision "file", source: "./.env/az-537298-GCP.json", destination: "/home/vagrant/.env/az-537298-GCP.json"
    tfbuntu.vm.provision "file", source: "./.env/env_local", destination: "/home/vagrant/.env/env_local"
    
    ##### Check if the files were provisioned successfully
    tfbuntu.vm.provision "shell", inline: <<-SHELL
      if [[ ! -f /home/vagrant/.env/env_local ]]; then
        echo "Error: 'env_local' was not provisioned successfully."
        exit 1
      fi
        
      echo "ENV file was provisioned successfully."
    SHELL

    ##### Install packages
    tfbuntu.vm.provision "shell", path: "scripts/tf-provision.sh"

    ##### GCP gcloud configuration
    tfbuntu.vm.provision "shell" do |vs|
      vs.path = "scripts/gcloud-setup.sh"
      vs.privileged = false
    end

  end
  
end
