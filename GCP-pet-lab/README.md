### 2024-10-21  16:05
---------------------

The project of Pet Clinic in GCP environment.
To run `gcloud` and `terraform` commands in the Google Cloud environment, a virtual machine `tfubuntu` was specially launched and configured.

Therefore, to deploy the project to Google, the script `6-create-templates.sh` and the directory `tfinfra` should be copied to the home directory of the specified virtual machine.

The `7-create-templates.sh` script does the preparatory work:
- it creates a Google Cloud Storage (a bucket) and uploads a few files on it;
- it creates disk images and templates for servers.

The directory `tfbucket` creates a Google Cloud Storage (a bucket) and uploads a few files on it (if you don't need to run `7-create-templates.tf` to create templates.

The deployment order using Terraform:
```bash
cd tfinfra
terraform init -backend-config=terreform.tfvars
terraform fmt
terraform validate
terraform apply -auto-approve -input=false
terraform show
terraform destroy -auto-approve -input=false
```