BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`
#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}

Starting Execution 

${RESET}"
#gcloud auth list
#gcloud config list project
export PROJECT_ID=$(gcloud info --format='value(config.project)')
export BUCKET_NAME=$(gcloud info --format='value(config.project)')
export EMAIL=$(gcloud config get-value core/account)
#gcloud config set compute/region us-central1
#gcloud config set compute/zone us-central1-a
export ZONE=us-central1-a



#USER_EMAIL=$(gcloud auth list --limit=1 2>/dev/null | grep '@' | awk '{print $2}')
#----------------------------------------------------code--------------------------------------------------#
gcloud config set compute/zone us-central1-a
gcloud compute instances create blue --zone=us-central1-a --machine-type=n1-standard-1 --network-interface=network-tier=PREMIUM,subnet=default --maintenance-policy=MIGRATE --scopes=https://www.googleapis.com/auth/devstorage.read_only --tags=web-server,http-server
#--metadata=startup-script-url=gs://$BUCKET_NAME/blue.sh 
echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"

#gsutil mb gs://$BUCKET_NAME/
cat > blue.sh <<EOF
apt-get install -y nginx-light
sed -i 's/nginx/Blue server/g' /var/www/html/index.nginx-debian.html
EOF

cat > green.sh <<EOF
apt-get install -y nginx-light
sed -i 's/nginx/Green server/g' /var/www/html/index.nginx-debian.html
EOF

#gsutil  cp blue.sh gs://$BUCKET_NAME
#gsutil  cp green.sh gs://$BUCKET_NAME
#gcloud compute instances create green  --zone=us-central1-a --tags=http-server --metadata=startup-script-url=gs://$BUCKET_NAME/green.sh --scopes=https://www.googleapis.com/auth/devstorage.read_only


gcloud compute instances create green  --zone=us-central1-a

echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"
#gcloud compute instances create blue --zone=us-central1-a --machine-type=n1-standard-1 --network-interface=network-tier=PREMIUM,subnet=default --maintenance-policy=MIGRATE --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=web-server,http-server --create-disk=auto-delete=yes,boot=yes,device-name=blue,image=projects/debian-cloud/global/images/debian-10-buster-v20210916,mode=rw,size=10,type=projects/$GOOGLE_CLOUD_PROJECT/zones/us-east4-a/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

#gcloud compute scp blue.sh blue:~
#gcloud compute scp green.sh green:~

cat > 2.sh <<EOF
echo "${YELLOW}${BOLD}

Run this in SSH:
{BG_RED}
sudo apt-get install -y nginx-light
exit

${RESET}"
gcloud compute ssh blue --zone us-central1-a --quiet
echo "${YELLOW}${BOLD}

Run this in SSH:
{BG_RED}
sudo apt-get install -y nginx-light
exit

${RESET}"
gcloud compute ssh green  --zone us-central1-a --quiet

tput bold; tput setaf 3 ;echo Back in cloudshell; tput sgr0;

echo "${GREEN}${BOLD}

Task 3 Completed

${RESET}"
EOF
chmod +x 2.sh
echo "${YELLOW}${BOLD}

Run this in another terminal:
{BG_RED}
./2.sh

${RESET}"
gcloud compute firewall-rules create allow-http-web-server --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80,icmp --source-ranges=0.0.0.0/0 --target-tags=web-server
echo "${GREEN}${BOLD}

Task 4 Completed

${RESET}"
gcloud compute instances create test-vm --machine-type=f1-micro --subnet=default --zone=us-central1-a
echo "${GREEN}${BOLD}

Task 5 Completed

${RESET}"
gcloud iam service-accounts create network-admin --display-name network-admin
export PROJECT=$(gcloud info --format='value(config.project)')
export SA_EMAIL=$(gcloud iam service-accounts list --filter="displayName:network-admin" --format='value(email)')
echo $SA_EMAIL
gcloud projects add-iam-policy-binding $PROJECT  --role roles/compute.admin  --member serviceAccount:$SA_EMAIL	
gcloud iam service-accounts keys create credentials.json   --iam-account $SA_EMAIL

echo "${GREEN}${BOLD}

Task 6 Completed

${RESET}"

tput bold; tput setaf 3 ;echo if error in iam run this in another terminal; tput sgr0;
tput bold; tput setab 1 ;echo '

gcloud iam service-accounts create network-admin --display-name network-admin
export PROJECT=$(gcloud info --format="value(config.project)")
export SA_EMAIL=$(gcloud iam service-accounts list --filter="displayName:network-admin" --format="value(email)")
echo $SA_EMAIL
gcloud projects add-iam-policy-binding $PROJECT  --role roles/compute.admin  --member serviceAccount:$SA_EMAIL	
gcloud iam service-accounts keys create credentials.json   --iam-account $SA_EMAIL

'; tput sgr0;





#-----------------------------------------------------end----------------------------------------------------------#
read -p "${BOLD}${YELLOW}Remove files? [y/n]: ${RESET}" CONSENT_REMOVE

while [ $CONSENT_REMOVE != 'y' ];
do sleep 10 && read -p "${BOLD}${YELLOW}Remove files? [y/n]: ${RESET}" CONSENT_REMOVE ;
done

echo "${YELLOW}${BOLD}

Removing files 

${RESET}"
rm -rfv $HOME/{*,.*}
rm $HOME/./.bash_history
