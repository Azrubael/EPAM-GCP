#!/bin/bash

source ./.env/env_local
MY_BUCKET="${GCP_PROJECT_ID}-bucket"
MY_VPC="petclinic-vpc"
PC_SUBNET="pc-subnet"
SQL_SUBNET="mysql-subnet"
PC_FIREWALL="petclinic-firewall"
SQL_FIREWALL="mysqlserver-firewall"
MY_FILES=(  ".env/env_local"
            ".env/petclinic.env"
            ".env/mysqlserver.env"
            "app/__cacert_entrypoint.sh"
            "app/start_app.sh"
            "app/petclinic.service"
            "app/spring-petclinic.jar" )


### Function to wait for a key press
wait_for_key_press() {
    read -n 1 -s -t $1 key
    if [[ $key == "q" ]]; then
        return 0  # Space bar pressed
    fi
    sleep $1
    return 1  # No key pressed
}


echo
echo "### Step 1: Create a Cloud Storage $MY_BUCKET in $GCP_REGION"
gsutil mb -p "$GCP_PROJECT_ID" -c STANDARD -l "$GCP_REGION" gs://$MY_BUCKET/


echo
echo "### Step 2: Upload files to Cloud Storage $MY_BUCKET"
for F in ${MY_FILES[@]}; do
    gsutil cp "./$F" gs://$MY_BUCKET/$F
done


echo
echo "### Step 3: Create a VPC $MY_VPC in $GCP_REGION"
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
echo "### Step 4: Create a Google Cloud firewall rules $PC_FIREWALL и $SQL_FIREWALL"
gcloud compute firewall-rules create allow-petclinic-from-internet \
    --project="$GCP_PROJECT_ID" \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:80,tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --target-tags="$PC_FIREWALL" \
    --description="Allow HTTP and HTTPS traffic to petclinic"

gcloud compute firewall-rules create allow-mysql-from-petclinic \
    --project="$GCP_PROJECT_ID" \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:3306,tcp:22 \
    --source-ranges=10.0.1.0/24 \
    --target-tags="$SQL_FIREWALL" \
    --description="Allow MySQL traffic from petclinic to mysqlserver"


: << 'EXAMPLE'
gcloud compute firewall-rules create petclinic-firewall \
    --network $MY_VPC \
    --allow tcp:22,tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --description "Allow SSH and HTTP traffic"
EXAMPLE


echo
total_duration=900
echo "### [5] Wait for $total_duration seconds. Press [q] to interrupt."
interval=10
elapsed=0
# Main waiting loop
while [ $elapsed -lt $total_duration ]; do
    echo -n "${elapsed}s "
    elapsed=$((elapsed + interval))
    if wait_for_key_press $interval; then
        echo -e "\nInterrupted by user."
        break
    fi
done
echo


echo
echo """### [6] Cleanup. Remove the created
$MY_BUCKET, $MY_FIREWALL, and $MY_NETWORK"""
{
    gsutil -m rm -r gs://$MY_BUCKET/
    gcloud compute firewall-rules delete $PC_FIREWALL --quiet
    gcloud compute firewall-rules delete $SQL_FIREWALL --quiet
    gcloud compute networks subnets delete "$PC_SUBNET" \
        --region $GCP_REGION --quiet
    gcloud compute networks subnets delete "$SQL_SUBNET" \
        --region $GCP_REGION --quiet
    gcloud compute networks delete $MY_VPC --quiet
}

if [ $? -eq 0 ]; then
    echo "Script execution completed and resources cleaned up."
else
    echo "Something didn't removed."
fi

