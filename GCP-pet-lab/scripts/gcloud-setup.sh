#!/bin/bash

ENV_FILE="/home/vagrant/.env/env_local"

echo
echo "### [11] Initialization of SDK with  the required environment variables"
echo "Loading the default settings..."
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
    echo "source $ENV_FILE" >> /home/vagrant/.bashrc
else
    echo "Error: $ENV_FILE file not found!"
    exit 1
fi


echo
echo "### [12] Authenticate using the service account key file"
if [ -f "$GCP_KEY_FILE" ]; then
    gcloud auth activate-service-account --key-file $GCP_KEY_FILE
    gcloud config set account "$(gcloud config get-value account)"
else
    echo "Error: Service account key file $GCP_KEY_FILE not found!"
    exit 1
fi

if [ -z "$GCP_PROJECT_ID" ] || [ -z "$GCP_ZONE" ] || [ -z "$GCP_REGION" ]; then
    echo "Error: One or more required environment variables are not set in ./env_local."
    exit 1
fi

echo
echo "Project ID = $GCP_PROJECT_ID"
echo "GCP_REGION = $GCP_REGION"
echo "GCP_ZONE = $GCP_ZONE"
gcloud config set account "$GCP_ACCOUNT"
gcloud config set project "$GCP_PROJECT_ID"
gcloud config set compute/zone "$GCP_ZONE"
gcloud config set compute/region "$GCP_REGION"


echo
echo "### [13] Google Cloud SDK initialized with the following settings:"
gcloud config list
echo
echo "Check if the instance authenticated..."
gcloud auth activate-service-account --key-file="$GCP_KEY_FILE"
gcloud auth list


echo
echo "### [14] Trying to find any instances in the current project and GCP_ZONE"
###### List the instances in the current project and zone
instances=$(gcloud compute instances list --format="value(name)")
if [ -z "$instances" ]; then
    echo "No Google Compute Engine instances found in the project."
else
    echo "Provisioned Google Compute Engine instances:"
    echo "$instances"
fi


: <<'DEBUGGING'
sudo apt install openjdk-17-jdk -y --fix-missing
sudo apt --fix-broken install
curl localhost:8080
### If you need to try the ssh connect
ssh -i /home/vagrant/.ssh/merlin_key silver@192.168.56.19
### eval $(ssh-agent)
### ssh-add $KEY_PATH
DEBUGGING
