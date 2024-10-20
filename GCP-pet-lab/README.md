### 2024-10-19  19:19
---------------------

The project of Pet Clinic in GCP environment.
To run `gcloud` and `terraform` commands in the Google Cloud environment, a virtual machine `tfubuntu` was specially launched and configured.

Therefore, to deploy the project to Google, the script `6-create-templates.sh` and the directory `tfinfra` should be copied to the home directory of the specified virtual machine.

The `6-create-templates.sh` script does the preparatory work, it creates disk images and templates for servers.

Then the infrastructure is deployed using terraform.