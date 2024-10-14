#!/bin/bash
sudo apt-get update

echo "### [1] Install the necessary packages for adding a new repository over HTTPS"
sudo apt-get update
sudo apt-get install mc apt-transport-https ca-certificates gnupg -y


echo
echo "### [2] Import the Google Cloud public key"
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg


echo
echo "### [3] Install the Google Cloud SDK"
sudo apt-get update
sudo apt-get install google-cloud-sdk -y


# echo "### [4] Install additional components (optional instead of the above)
# sudo apt-get install google-cloud-cli -y
# sudo apt-get install google-cloud-cli-app-engine-python -y

# sudo apt-get install apache2-utils -y
# Usage example:    $ ab -n 1000 -c 100 http://<YOUR_NGINX_SERVER_IP>/
