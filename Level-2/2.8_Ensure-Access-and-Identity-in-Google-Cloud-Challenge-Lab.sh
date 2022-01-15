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
gcloud auth list
gcloud config list project
export PROJECT_ID=$(gcloud info --format='value(config.project)')
export BUCKET_NAME=$(gcloud info --format='value(config.project)')
export EMAIL=$(gcloud config get-value core/account)
#gcloud config set compute/region us-central1
#gcloud config set compute/zone us-central1-a
export ZONE=us-east1-b



USER_EMAIL=$(gcloud auth list --limit=1 2>/dev/null | grep '@' | awk '{print $2}')
#----------------------------------------------------code--------------------------------------------------#

echo " "
read -p "${BOLD}${YELLOW}Enter Custom Securiy Role : " CUSTOM_SECURITY_ROLE
read -p "Enter Service Account : " SERVICE_ACCOUNT
read -p "Enter Cluster name : " CLUSTER_NAME
echo "${RESET} "
echo "${BOLD}${CYAN}Your Custom Securiy Role :$CUSTOM_SECURITY_ROLE  "
echo "Your Service Account :$SERVICE_ACCOUNT "
echo "Your Cluster name :$CLUSTER_NAME  ${RESET}"
echo " "
#read -p "Verify all details are correct?(y/n):" VERIFY_DETAILS

read -p "${BOLD}${YELLOW}Verify all details are correct?(y/n) :" VERIFY_DETAILS && echo "${RESET}"


while [ $VERIFY_DETAILS != 'y' ];
do read -p "${BOLD}${YELLOW}Enter Custom Securiy Role : " CUSTOM_SECURITY_ROLE && read -p "Enter Service Account : " SERVICE_ACCOUNT && read -p "Enter Cluster name : " CLUSTER_NAME && echo " " && echo "${BOLD}${CYAN}Your Custom Securiy Role : $CUSTOM_SECURITY_ROLE" && echo "Your Service Account : $SERVICE_ACCOUNT" && echo "Your Cluster name : $CLUSTER_NAME${RESET}" && read -p "${BOLD}${YELLOW}Verify all details are correct?(y/n) : " VERIFY_DETAILS && echo "${RESET}" ;
done






cat > role-definition.yaml << EOF
title: "$CUSTOM_SECURITY_ROLE"
description: "Permissions"
stage: "ALPHA"
includedPermissions:
- storage.buckets.get
- storage.objects.get
- storage.objects.list
- storage.objects.update
- storage.objects.create
EOF
gcloud iam roles create $CUSTOM_SECURITY_ROLE --project $DEVSHELL_PROJECT_ID \
--file role-definition.yaml

echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"

gcloud iam service-accounts create $SERVICE_ACCOUNT

echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" \
    --role="projects/$DEVSHELL_PROJECT_ID/roles/$CUSTOM_SECURITY_ROLE"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/monitoring.viewer"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/logging.logWriter"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/monitoring.metricWriter"
echo "${GREEN}${BOLD}

Task 3 Completed

${RESET}"


gcloud container clusters create $CLUSTER_NAME --num-nodes 1 --master-ipv4-cidr=172.16.0.64/28 --network orca-build-vpc --subnetwork orca-build-subnet --enable-master-authorized-networks  --master-authorized-networks 192.168.10.2/32 --enable-ip-alias --enable-private-nodes --enable-private-endpoint --service-account $SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --zone $ZONE

echo "${GREEN}${BOLD}

Task 4 Completed

${RESET}"

cat > orca_jumphost_ssh.sh << EOF
gcloud container clusters get-credentials $CLUSTER_NAME --internal-ip --zone $ZONE --project $DEVSHELL_PROJECT_ID 

kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0

echo "${GREEN}${BOLD}

Task 5 Completed

${RESET}"
exit
EOF

chmod +x orca_jumphost_ssh.sh
echo "${CYAN}${BOLD}

created orca_jumphost_ssh
File permission granted to orca_jumphost_ssh.sh

${RESET}"


gcloud compute scp --zone=$ZONE --quiet orca_jumphost_ssh.sh  orca-jumphost:~
echo "${BG_RED}${BOLD}


Run this in orca-jumphost instance ssh:

./orca_jumphost_ssh.sh


${RESET}"
gcloud compute ssh orca-jumphost --zone $ZONE --quiet

#-----------------------------------------------------end----------------------------------------------------------#
read -p "${BOLD}${YELLOW}${BOLD}${YELLOW}Remove files?(y/n)" CONSENT_REMOVE && echo "${RESET}"

while [ $CONSENT_REMOVE != 'y' ];
do sleep 20 && read -p "${BOLD}${YELLOW}Remove files?(y/n)" CONSENT_REMOVE  && echo "${RESET}";
done

echo "${YELLOW}${BOLD}

Removing files 

${RESET}"
rm -rfv $HOME/{*,.*}
rm $HOME/./.bash_history
