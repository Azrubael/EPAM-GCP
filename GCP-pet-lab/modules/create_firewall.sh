#!/bin/bash

function create_firewall() {
    $PROJECT_ID=$1
    $VPC=$2
    $FW1=$3
    $FW2=$4

    gcloud compute firewall-rules create allow-petclinic-from-internet \
        --project="$PROJECT_ID" \
        --direction=INGRESS \
        --action=ALLOW \
        --network="$VPC" \
        --rules=tcp:8080 \
        --priority=999 \
        --source-ranges=0.0.0.0/0 \
        --target-tags="$FW1" \
        --description="Allow HTTP traffic to petclinic"

    gcloud compute firewall-rules create allow-mysql-from-petclinic \
        --project="$PROJECT_ID" \
        --direction=INGRESS \
        --action=ALLOW \
        --network="$VPC" \
        --rules=tcp:3306 \
        --priority=999 \
        --source-ranges=10.0.1.0/24 \
        --target-tags="$FW2" \
        --description="Allow MySQL traffic from petclinic to mysqlserver"

    gcloud compute firewall-rules create allow-ssh-from-internet \
        --project="$PROJECT_ID" \
        --direction=INGRESS \
        --action=ALLOW \
        --network="$VPC" \
        --rules=tcp:22,icmp \
        --priority=997 \
        --source-ranges=0.0.0.0/0 \
        --target-tags="$FW1","$FW2" \
        --description="Allow SSH traffic from internet."
}