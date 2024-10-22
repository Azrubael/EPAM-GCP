source ~/.env/env_local
ZONES="$REGION-c,$REGION-f"
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

PC_MIG="pc-mig"
MIN_SIZE=2
MAX_SIZE=4


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
    --priority=999 \
    --source-ranges=0.0.0.0/0 \
    --target-tags="$PC_FIREWALL" \
    --description="Allow HTTP traffic to petclinic"

gcloud compute firewall-rules create allow-mysql-from-petclinic \
    --project="$GCP_PROJECT_ID" \
    --direction=INGRESS \
    --action=ALLOW \
    --network="$MY_VPC" \
    --rules=tcp:3306 \
    --priority=999 \
    --source-ranges=10.0.1.0/24 \
    --target-tags="$SQL_FIREWALL" \
    --description="Allow MySQL traffic from petclinic to mysqlserver"

gcloud compute firewall-rules create allow-ssh-from-internet \
    --project="$GCP_PROJECT_ID" \
    --direction=INGRESS \
    --action=ALLOW \
    --network="$MY_VPC" \
    --rules=tcp:22,icmp \
    --priority=997 \
    --source-ranges=0.0.0.0/0 \
    --target-tags="$PC_FIREWALL","$SQL_FIREWALL" \
    --description="Allow SSH traffic from internet."

# Create NAT
gcloud compute routers create pc-router \
    --network=$MY_VPC \
    --region=$GCP_REGION \
    --asn=65001
gcloud compute routers nats create pc-nat-gateway \
    --router=pc-router \
    --region=$GCP_REGION \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips \
    --network-service-tier=STANDARD \
    --log-configuration=NONE


# Create a health check ---------------------------------------
gcloud compute health-checks create http petclinic-health-check \
    --port 8080 \
    --request-path /health \
    --check-interval 30s \
    --timeout 10s \
    --healthy-threshold 2 \
    --unhealthy-threshold 2

# Create a backend service ------------------------------------
gcloud compute backend-services create petclinic-backend \
    --protocol HTTP \
    --health-checks petclinic-health-check \
    --global \
    --load-balancing-scheme=EXTERNAL \
    --project=$GCP_PROJECT_ID

# Add the managed instance group to the backend service -------
gcloud compute backend-services add-backend petclinic-backend \
    --instance-group=$PC_MIG \
    --instance-group-zone=$GCP_ZONES \
    --global \
    --project=$GCP_PROJECT_ID

# Create a URL map --------------------------------------------
gcloud compute url-maps create petclinic-url-map \
    --default-service petclinic-backend \
    --project=$GCP_PROJECT_ID

# Create a target HTTP proxy ----------------------------------
gcloud compute target-http-proxies create petclinic-http-proxy \
    --url-map petclinic-url-map \
    --project=$GCP_PROJECT_ID

# Create a global forwarding rule -----------------------------
gcloud compute forwarding-rules create petclinic-forwarding-rule \
    --global \
    --target-http-proxy petclinic-http-proxy \
    --ports 80 \
    --name petclinic-forwarding-rule \
    --project=$GCP_PROJECT_ID


# Create the managed instance group
gcloud beta compute instance-groups managed create $PC_MIG \
    --project=$GCP_PROJECT_ID \
    --base-instance-name=$PC_SRV \
    --template=$PC_TEMPLATE \
    --size=$MIN_SIZE \
    --zones=$GCP_ZONES \
    --target-distribution-shape=EVEN \
    --instance-redistribution-type=proactive \
    --default-action-on-vm-failure=repair \
    --region=$GCP_REGION \
    --no-force-update-on-repair \
    --list-managed-instances-results=pageless

gcloud compute instance-groups managed set-autoscaling $PC_MIG \
    --project=$GCP_PROJECT_ID \
    --region=$GCP_REGION \
    --mode=on \
    --min-num-replicas=$MIN_SIZE \
    --max-num-replicas=$MAX_SIZE \
    --stackdriver-metric-filter=resource.type\ =\ \"gce_instance\" \
    --update-stackdriver-metric=compute.googleapis.com/instance/uptime \
    --stackdriver-metric-utilization-target=120.0 \
    --stackdriver-metric-utilization-target-type=delta-per-second \
    --cool-down-period=60

gcloud beta compute instance-groups managed update-autoscaling $PC_MIG \
    --project=$GCP_PROJECT_ID \
    --region=$GCP_REGION \
    --min-num-replicas=$MIN_SIZE \
    --mode=on \
    --scale-in-control=max-scaled-in-replicas=$MAX_SIZE,time-window=60 \
    --set-schedule=az-scedule \
    --schedule-cron='0 10 * * *' \
    --schedule-duration-sec=18000 \
    --schedule-time-zone='Europe/Kiev' \
    --schedule-min-required-replicas=$MIN_SIZE \
    --schedule-description='EPAM Lab Autoscaler with cron schedule'

