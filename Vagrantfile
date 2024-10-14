# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
  
  ### ----- gcpcli vm -----
  config.vm.define "gcpcli" do |gcpcli|
    gcpcli.vm.box = "ubuntu/focal64"
    gcpcli.vm.hostname = "gcpcli"
    gcpcli.vm.network "private_network", ip: "192.168.56.12"
    gcpcli.vm.synced_folder ".", "/vagrant", disabled: false
    gcpcli.vm.provider "virtualbox" do |ubuntu20|
      ubuntu20.name = "gcpcli-lab"
      ubuntu20.memory = "1600"
      ubuntu20.cpus = 2
      ubuntu20.customize ["modifyvm", :id, "--vram", "16"]
    end

    gcpcli.vm.provision "file", source: "./scripts/webserver-start.sh", destination: "/home/vagrant/webserver-start.sh"
    gcpcli.vm.provision "file", source: "./scripts/webserver-terminate.sh", destination: "/home/vagrant/webserver-terminate.sh"
    gcpcli.vm.provision "file", source: "./.env/az-537298-GCP.json", destination: "/home/vagrant/.env/az-537298-GCP.json"
    gcpcli.vm.provision "file", source: "./.env/env_local", destination: "/home/vagrant/.env/env_local"
    
    ##### Check if the files were provisioned successfully
    gcpcli.vm.provision "shell", inline: <<-SHELL
      if [[ ! -f /home/vagrant/.env/env_local ]]; then
        echo "Error: 'env_local' was not provisioned successfully."
        exit 1
      fi
        
      echo "ENV file was provisioned successfully."
    SHELL

    ##### Install packages
    gcpcli.vm.provision "shell", path: "scripts/gcpcli-provision.sh"

    ##### GCP CLI configuration
    gcpcli.vm.provision "shell" do |vs|
      vs.path = "scripts/gcpcli-setup.sh"
      vs.privileged = false
    end
    

  end
  
end
