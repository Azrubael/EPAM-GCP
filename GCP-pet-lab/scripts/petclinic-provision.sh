#!/bin/bash

set -e
sudo timedatectl set-timezone Europe/Kyiv

sudo apt-get update
sudo apt-get install -y openjdk-17-jre
mkdir -p /app

# Get the bucket name from metadata
BUCKET_NAME=$(curl -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/attributes/gs_bucket)

# Download files from the specified Google Cloud Storage bucket
gsutil -m cp -r gs://$BUCKET_NAME/app/spring-petclinic.jar /app/spring-petclinic.jar
gsutil -m cp -r gs://$BUCKET_NAME/app/__cacert_entrypoint.sh /app/__cacert_entrypoint.sh
gsutil -m cp -r gs://$BUCKET_NAME/app/start_app.sh /app/start_app.sh
gsutil -m cp -r gs://$BUCKET_NAME/app/petclinic.service /app/petclinic.service
gsutil -m cp -r gs://$BUCKET_NAME/.env/petclinic.env /app/petclinic.env

sudo mv /app/petclinic.service /etc/systemd/system/petclinic.service

source /app/petclinic.env
sudo cat /app/petclinic.env >> /etc/profile.d/provision.env.sh
sudo chmod +x /etc/profile.d/provision.env.sh
sudo chmod +x /app/start_app.sh

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