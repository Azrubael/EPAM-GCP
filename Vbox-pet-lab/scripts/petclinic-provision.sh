#!/bin/bash

set -e  # Stop the script if an error happened

sudo apt-get update
sudo apt-get install -y openjdk-17-jre
mkdir -p /app
mv /home/vagrant/spring-petclinic.jar /app/spring-petclinic.jar
mv /home/vagrant/__cacert_entrypoint.sh /app/__cacert_entrypoint.sh
mv /home/vagrant/start_app.sh /app/start_app.sh
mv /home/vagrant/petclinic.env /app/petclinic.env
sudo mv /home/vagrant/petclinic.service /etc/systemd/system/petclinic.service

source /app/petclinic.env
sudo cat /app/petclinic.env >> /etc/profile.d/provision.env.sh
sudo chmod +x /etc/profile.d/provision.env.sh
rm /app/petclinic.env

sudo systemctl daemon-reload
sudo systemctl enable petclinic.service
sudo systemctl start petclinic.service


# Check the petclinic.service state
if systemctl is-active --quiet petclinic.service; then
    echo "Petclinic is running OK."
    exit 0
else
    echo "Petclinic didn't start."
    exit 1
fi