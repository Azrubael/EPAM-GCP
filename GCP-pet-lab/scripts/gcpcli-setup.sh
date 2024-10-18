#!/bin/bash

### The script to setup a VM instance, that was
### launched in VirtualBox with 'gcpcli-provision.sh'


ENV_FILE="/home/vagrant/.env/env_local"

echo
echo "### [5] Initialization of SDK with  the required environment variables"
echo "Loading the default settings..."
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
    echo "source $ENV_FILE" >> /home/vagrant/.bashrc
else
    echo "Error: $ENV_FILE file not found!"
    exit 1
fi


echo
echo "### [6] Authenticate using the service account key file"
if [ -f "$KEY_FILE" ]; then
    gcloud auth activate-service-account --key-file $KEY_FILE
    gcloud config set account "$(gcloud config get-value account)"
else
    echo "Error: Service account key file $KEY_FILE not found!"
    exit 1
fi

if [ -z "$CLOUDSDK_CORE_PROJECT" ] || [ -z "$ZONE" ] || [ -z "$REGION" ]; then
    echo "Error: One or more required environment variables are not set in ./env_local."
    exit 1
fi

echo
echo "Project ID = $CLOUDSDK_CORE_PROJECT"
echo "Region = $REGION"
echo "Zone = $ZONE"
gcloud config set account "$ACCOUNT"
gcloud config set project "$CLOUDSDK_CORE_PROJECT"
gcloud config set compute/zone "$ZONE"
gcloud config set compute/region "$REGION"


echo
echo "### [7] Google Cloud SDK initialized with the following settings:"
gcloud config list
echo
echo "Check if the instance authenticated..."
gcloud auth activate-service-account --key-file="$KEY_FILE"
gcloud auth list


echo
echo "### [8] Trying to find any instances in the current project and zone"
###### List the instances in the current project and zone
instances=$(gcloud compute instances list --format="value(name)")
if [ -z "$instances" ]; then
    echo "No Google Compute Engine instances found in the project."
else
    echo "Provisioned Google Compute Engine instances:"
    echo "$instances"
fi

