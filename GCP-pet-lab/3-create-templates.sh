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

SQL_SUBNET="mysql-subnet"
SQL_FIREWALL="mysqlserver-firewall"
SQL_SRV="mysql-server"


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
gcloud compute firewall-rules create allow-petclinic-from-internet \
    --project="$GCP_PROJECT_ID" \
    --direction=INGRESS \
    --action=ALLOW \
    --network="$MY_VPC" \
    --rules=tcp:8080 \
    --priority=1000 \
    --source-ranges=0.0.0.0/0 \
    --target-tags="$PC_FIREWALL" \
    --description="Allow HTTP traffic to petclinic"

gcloud compute firewall-rules create allow-mysql-from-petclinic \
    --project="$GCP_PROJECT_ID" \
    --direction=INGRESS \
    --action=ALLOW \
    --network="$MY_VPC" \
    --rules=tcp:3306 \
    --priority=1000 \
    --source-ranges=10.0.1.0/24 \
    --target-tags="$SQL_FIREWALL" \
    --description="Allow MySQL traffic from petclinic to mysqlserver"

gcloud compute firewall-rules create allow-ssh-from-internet \
    --project="$GCP_PROJECT_ID" \
    --direction=INGRESS \
    --action=ALLOW \
    --network="$MY_VPC" \
    --rules=tcp:22,icmp \
    --priority=999 \
    --source-ranges=0.0.0.0/0 \
    --target-tags="$PC_FIREWALL","$SQL_FIREWALL" \
    --description="Allow SSH traffic from internet."


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
total_duration=900
echo "### Step 7 -- Wait for $total_duration seconds. Press [q] to interrupt."
interval=10
elapsed=0
source ./modules/waiting.sh
waiting $total_duration $interval $elapsed


echo
echo """### Step 8 -- Removing the servers $PC_SRV, $SQL_SRV,
the bucket $MY_BUCKET, the VPC $MY_VPC with subnets $PC_SUBNET and $SQL_SUBNET"""
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


echo
echo "### Step 9 -- Listing available disks:"
gcloud compute disks list --project="$GCP_PROJECT_ID"

