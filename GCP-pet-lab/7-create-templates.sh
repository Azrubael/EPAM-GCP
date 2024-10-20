#!/bin/bash

source ./.env/env_local
MY_BUCKET="${GCP_PROJECT_ID}-bucket"
MY_VPC="petclinic-vpc"
MY_FILES=(  "app/spring-petclinic.jar"
            "app/__cacert_entrypoint.sh"
            "app/start_app.sh"
            "app/petclinic.service"
            ".env/env_local"
            ".env/petclinic.env"
            ".env/mysqlserver.env" )

PC_SUBNET="pc-subnet"
PC_FIREWALL="petclinic-firewall"
PC_SRV="petclinic-server"
PC_IMAGE="petclinic-image"
PC_TEMPLATE="petclinic-template"

SQL_SUBNET="mysql-subnet"
SQL_FIREWALL="mysqlserver-firewall"
SQL_SRV="mysql-server"
SQL_IMAGE="mysqlserver-image"
SQL_TEMPLATE="mysqlserver-template"


echo
echo "### Step 1 -- Create a Cloud Storage $MY_BUCKET in $GCP_REGION"
gsutil mb -p "$GCP_PROJECT_ID" -c STANDARD -l "$GCP_REGION" gs://$MY_BUCKET/


echo
echo "### Step 2: Upload files to Cloud Storage $MY_BUCKET"
for F in ${MY_FILES[@]}; do
    gsutil cp "./$F" gs://$MY_BUCKET/$F
done


echo
echo "### Step 3 -- Create a VPC $MY_VPC in $GCP_REGION"
gcloud compute networks create $MY_VPC --subnet-mode=custom
gcloud compute networks subnets create "$PC_SUBNET" \
    --network $MY_VPC \
    --range 10.0.1.0/24 \
    --region $GCP_REGION
gcloud compute networks subnets create "$SQL_SUBNET" \
    --network $MY_VPC \
    --range 10.0.2.0/24 \
    --region $GCP_REGION


echo
echo "### Step 4 -- Create a Google Cloud firewall rules $PC_FIREWALL и $SQL_FIREWALL"
source ./modules/create_firewall.sh
create_firewall $GCP_PROJECT_ID $MY_VPC $PC_FIREWALL $SQL_FIREWALL


echo
echo "### Step 5 -- Create a $PC_SRV instance"
gcloud compute instances create $PC_SRV \
    --project="$GCP_PROJECT_ID" \
    --zone="$GCP_ZONE" \
    --machine-type=g1-small \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet="$PC_SUBNET" \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account="$GCP_SERVICE_ACCOUNT" \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
    --tags=http-server,"$PC_FIREWALL","$PC_SRV",lb-health-check \
    --create-disk=boot=yes,device-name="${PC_SRV}-disk",image=projects/debian-cloud/global/images/debian-11-bullseye-v20241009,mode=rw,size=10,type=pd-standard \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=app=petclinic \
    --reservation-affinity=any \
    --metadata gs_bucket="$MY_BUCKET" \
    --metadata-from-file=startup-script=scripts/petclinic-provision.sh


echo
echo "### Step 6 -- Create a $SQL_SRV instance"
gcloud compute instances create $SQL_SRV \
    --project="$GCP_PROJECT_ID" \
    --zone="$GCP_ZONE" \
    --machine-type=g1-small \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet="$SQL_SUBNET" \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account="$GCP_SERVICE_ACCOUNT" \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
    --tags=db-server,"$SQL_FIREWALL","$SQL_SRV",lb-health-check \
    --create-disk=boot=yes,device-name="${SQL_SRV}-disk",image=projects/debian-cloud/global/images/debian-11-bullseye-v20241009,mode=rw,size=10,type=pd-standard \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=app=petclinic \
    --reservation-affinity=any \
    --metadata gs_bucket="$MY_BUCKET" \
    --metadata-from-file=startup-script=scripts/mysqlserver-provision.sh


echo
delay7=900
echo """### Step 7 -- Wait for $delay7 seconds. Press [q] to interrupt
the waiting process and move further according the script."""
interval7=10
elapsed7=0
source ./modules/waiting.sh
waiting $delay7 $interval7 $elapsed7


echo
echo "### Step 8 -- Removing the $PC_SRV and $SQL_SRV instances"
if {
    gcloud compute instances delete $PC_SRV \
        --project="$GCP_PROJECT_ID" \
        --zone="$GCP_ZONE" \
        --quiet \
        --keep-disks=boot
    gcloud compute instances delete $SQL_SRV \
        --project="$GCP_PROJECT_ID" \
        --zone="$GCP_ZONE" \
        --quiet \
        --keep-disks=boot
    }; then
    echo "The servers $PC_SRV and $SQL_SRV removed."
else
    echo """
The servers $PC_SRV and $SQL_SRV didn't removed.
Something went wrong..."""
fi


echo
echo "### Step 9 -- Listing available disks:"
gcloud compute disks list --project="$GCP_PROJECT_ID"


echo
echo "### Step 10 -- Creating images $PC_IMAGE and $SQL_IMAGE:"
gcloud compute images create "$PC_IMAGE" \
    --project="$GCP_PROJECT_ID" \
    --storage-location=us \
    --source-disk="$PC_SRV" \
    --source-disk-zone="$GCP_ZONE" \
    --labels=app=petclinic \
    --description=GCP-pet-lab

gcloud compute images create "$SQL_IMAGE" \
    --project="$GCP_PROJECT_ID" \
    --storage-location=us \
    --source-disk="$SQL_SRV" \
    --source-disk-zone="$GCP_ZONE" \
    --labels=app=petclinic \
    --description=GCP-pet-lab 

echo    
echo "### Step 11 -- Listing images:"
gcloud compute disks list --project="$GCP_PROJECT_ID" --filter="$GCP_PROJECT_ID"


echo
echo "### Step 12 -- Creating templates $PC_TEMPLATE and $SQL_TEMPLATE:"
gcloud beta compute instance-templates create "$PC_TEMPLATE" \
    --project="$GCP_PROJECT_ID" \
    --machine-type=g1-small \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet="$PC_SUBNET" \
    --instance-template-region="$GCP_REGION" \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account="$GCP_SERVICE_ACCOUNT" \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
    --region="$GCP_REGION" \
    --tags=http-server,"$PC_FIREWALL","$PC_SRV",lb-health-check \
    --create-disk=auto-delete=yes,boot=yes,device-name="${PC_SRV}-disk",image=projects/"$GCP_PROJECT_ID"/global/images/"$PC_IMAGE",mode=rw,size=10,type=pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any

gcloud beta compute instance-templates create "$SQL_TEMPLATE" \
    --project="$GCP_PROJECT_ID" \
    --machine-type=g1-small \
    --network-interface=stack-type=IPV4_ONLY,subnet="$SQL_SUBNET",no-address \
    --instance-template-region="$GCP_REGION" \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account="$GCP_SERVICE_ACCOUNT" \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
    --region="$GCP_REGION" \
    --tags=db-server,"$SQL_FIREWALL","$SQL_SRV",lb-health-check \
    --create-disk=auto-delete=yes,boot=yes,device-name="${SQL_SRV}-disk",image=projects/"$GCP_PROJECT_ID"/global/images/"$SQL_IMAGE",mode=rw,size=10,type=pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any


echo    
echo "### Step 13 -- Listing available instance templates:"
gcloud compute instance-templates list --project="$GCP_PROJECT_ID"


echo
delay14=900
echo """### Step 14 -- Wait for $delay14 seconds. Press [q] to interrupt
and remove the bucket gs://$MY_BUCKET/ and network $MY_VPC."""
interval14=10
elapsed14=0
waiting $delay14 $interval14 $elapsed14


echo
echo "### Step 15 -- Cleaning up the infrastructure:"
if {
    gsutil -m rm -r gs://$MY_BUCKET/
    gcloud compute firewall-rules delete allow-petclinic-from-internet --quiet
    gcloud compute firewall-rules delete allow-mysql-from-petclinic --quiet
    gcloud compute firewall-rules delete allow-ssh-from-internet --quiet
    gcloud compute networks subnets delete "$PC_SUBNET" \
        --region $GCP_REGION --quiet
    gcloud compute networks subnets delete "$SQL_SUBNET" \
        --region $GCP_REGION --quiet
    gcloud compute networks delete $MY_VPC --quiet
    }; then
    echo "Script execution completed and resources cleaned up."
else
    echo "Something didn't removed."
fi