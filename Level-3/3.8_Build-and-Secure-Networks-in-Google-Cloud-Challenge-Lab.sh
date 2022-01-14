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
export ZONE=us-central1-a



USER_EMAIL=$(gcloud auth list --limit=1 2>/dev/null | grep '@' | awk '{print $2}')
#----------------------------------------------------code--------------------------------------------------#

echo " "
read -p "${BOLD}${YELLOW}Enter SSH IAP network tag : " IAP_NETWORK_TAG
read -p "Enter SSH internal network tag : " INTERNAL_NETWORK_TAG
read -p "Enter HTTP network tag : " HTTP_NETWORK_TAG
echo "${RESET} "
echo "${BOLD}${CYAN}Your SSH IAP network tag :$IAP_NETWORK_TAG  "
echo "Your SSH internal network tag :$INTERNAL_NETWORK_TAG  "
echo "Your HTTP network tag :$HTTP_NETWORK_TAG  ${RESET}"
echo " "
#read -p "Verify all details are correct?(y/n):" VERIFY_DETAILS

read -p "${BOLD}${YELLOW}Verify all details are correct?(y/n) :" VERIFY_DETAILS && echo "${RESET}"

while [ $VERIFY_DETAILS = n ];
do echo " " &&  read -p "${BOLD}${YELLOW}Enter SSH IAP network tag : " IAP_NETWORK_TAG && read -p "Enter SSH internal network tag : " INTERNAL_NETWORK_TAG && read -p "Enter HTTP network tag : " HTTP_NETWORK_TAG && echo "${RESET} " && echo "${BOLD}${CYAN}Your SSH IAP network tag :$IAP_NETWORK_TAG  " && echo "Your SSH internal network tag :$INTERNAL_NETWORK_TAG  " && echo "Your HTTP network tag :$HTTP_NETWORK_TAG  ${RESET}" && echo " " && read -p "${BOLD}${YELLOW}Verify all details are correct?(y/n) :" VERIFY_DETAILS && echo "${RESET}";
done


gcloud compute firewall-rules delete open-access --quiet

echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"


gcloud compute instances start bastion  --zone=us-central1-b



echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"


gcloud compute firewall-rules create $IAP_NETWORK_TAG  --allow=tcp:22 --source-ranges 35.235.240.0/20 --target-tags $IAP_NETWORK_TAG  --network acme-vpc
gcloud compute instances add-tags bastion --tags=$IAP_NETWORK_TAG  --zone=us-central1-b

echo "${GREEN}${BOLD}

Task 3 Completed

${RESET}"



gcloud compute firewall-rules create $HTTP_NETWORK_TAG  --allow=tcp:80 --source-ranges 0.0.0.0/0 --target-tags $HTTP_NETWORK_TAG  --network acme-vpc
gcloud compute instances add-tags juice-shop --tags=$HTTP_NETWORK_TAG  --zone=us-central1-b

echo "${GREEN}${BOLD}

Task 4 Completed

${RESET}"
gcloud compute firewall-rules create $INTERNAL_NETWORK_TAG --allow=tcp:22 --source-ranges 192.168.10.0/24 --target-tags $INTERNAL_NETWORK_TAG --network acme-vpc
gcloud compute instances add-tags juice-shop --tags=$INTERNAL_NETWORK_TAG --zone=us-central1-b
echo "${GREEN}${BOLD}

Task 5 Completed

${RESET}"


gcloud compute instances ssh bastion  --zone=us-central1-b --quiet

#-----------------------------------------------------end----------------------------------------------------------#
read -p "${BOLD}${YELLOW}${BOLD}${YELLOW}Remove files?(y/n)" CONSENT_REMOVE && echo "${RESET}"

while [ $CONSENT_REMOVE = n ];
do sleep 20 && read -p "${BOLD}${YELLOW}Remove files?(y/n)" CONSENT_REMOVE  && echo "${RESET}";
done

echo "${YELLOW}${BOLD}

Removing files 

${RESET}"
rm -rfv $HOME/{*,.*}
rm $HOME/./.bash_history
