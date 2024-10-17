#!/bin/bash

sudo apt-get update
sudo apt-get install -y openjdk-17-jre
mkdir -p /app
mv /home/vagrant/spring-petclinic.jar /app/spring-petclinic.jar
mv /home/vagrant/__cacert_entrypoint.sh /app/__cacert_entrypoint.sh
mv /home/vagrant/start_app.sh /app/start_app.sh
sudo mv /home/vagrant/petclinic.service /etc/systemd/system/petclinic.service


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