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
#export BUCKET_NAME=$(gcloud info --format='value(config.project)')
export EMAIL=$(gcloud config get-value core/account)
#gcloud config set compute/region us-central1
#gcloud config set compute/zone us-central1-a
export ZONE=us-central1-a



#USER_EMAIL=$(gcloud auth list --limit=1 2>/dev/null | grep '@' | awk '{print $2}')
#----------------------------------------------------code--------------------------------------------------#

gcloud compute networks create vpc-cluster --bgp-routing-mode=regional --subnet-mode=custom
gcloud compute networks subnets create cluster --network=vpc-cluster --range=192.168.110.0/24 --region=us-central1 --enable-private-ip-google-access
gcloud compute networks create vpc-management --bgp-routing-mode=regional --subnet-mode=custom
gcloud compute networks subnets create management --network=vpc-management --range=192.168.120.0/24 --region=us-central1 --enable-private-ip-google-access

gcloud compute instances create rdp-client --zone=us-central1-a  --machine-type=n1-standard-4 --image-project=qwiklabs-resources --image=sap-rdp-image --network=vpc-management --subnet=management --tags=rdp,http-server,https-server --boot-disk-type=pd-ssd

gcloud compute networks create vpc-prod --bgp-routing-mode=regional --subnet-mode=custom
gcloud compute networks subnets create prod --network=vpc-prod --range=10.0.0.0/24 --region=us-central1
gcloud compute networks create vpc-qa --bgp-routing-mode=regional --subnet-mode=custom
gcloud compute networks subnets create qa --network=vpc-qa --range=10.0.1.0/24 --region=us-central1
gcloud compute firewall-rules create ingress-qa --action allow --direction=INGRESS --source-ranges=0.0.0.0/0 --network=vpc-qa --rules all
gcloud compute firewall-rules create ingress-prod --action allow --direction=INGRESS --source-ranges=0.0.0.0/0 --network=vpc-prod --rules all
gcloud compute firewall-rules create rdp-management --action allow --direction=INGRESS --source-ranges=0.0.0.0/0 --network=vpc-management --rules tcp:3389


echo "${YELLOW}${BOLD}


Go here ${CYAN}https://console.cloud.google.com/marketplace/vm/config/checkpoint-public/check-point-cloudguard-payg?project=$PROJECT_ID ${YELLOW}and configure as described on lab page

${RESET}"
#echo "${GREEN}${BOLD}Task 1 Completed${RESET}"

gcloud compute instances add-tags check-point-cloudguard-payg-1-vm --zone $ZONE --tags=http-server,https-server

#https://console.cloud.google.com/compute/metadata?project=$PROJECT_ID&tab=sshkeys
#gcloud compute project-info describe --format='value(commonInstanceMetadata.ssh-keys)' |  awk '{print $2}'
#https://console.cloud.google.com/marketplace/vm/config/checkpoint-public/check-point-ha--byol?project=$PROJECT_ID

echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"
gcloud compute instances create linux-qa --zone us-central1-a --image-project=debian-cloud --image=debian-9-stretch-v20191210 --custom-cpu 1 --custom-memory 4 --network-interface subnet=qa,private-network-ip=10.0.1.4,no-address --metadata startup-script="\#! /bin/bash
useradd -m -p sa1trmaMoZ25A cp
EOF"
gcloud compute instances create linux-prod --zone us-central1-a --image-project=debian-cloud --image=debian-9-stretch-v20191210 --custom-cpu 1 --custom-memory 4 --network-interface subnet=prod,private-network-ip=10.0.0.4,no-address --metadata startup-script="\#! /bin/bash
useradd -m -p sa1trmaMoZ25A cp
EOF"
echo "${GREEN}${BOLD}

Task 2 Completed.

Game Completed.

${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#
read -p "${BOLD}${YELLOW}Remove files? [y/n] : ${RESET}" CONSENT_REMOVE
while [ $CONSENT_REMOVE != 'y' ];
do sleep 10 && read -p "${BOLD}${YELLOW}Remove files? [y/n] : ${RESET}" CONSENT_REMOVE ;
done

echo "${YELLOW}${BOLD}

Removing files 

${RESET}"
rm -rfv $HOME/{*,.*}
rm $HOME/./.bash_history
logout
exit
