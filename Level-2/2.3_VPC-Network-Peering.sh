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
#export EMAIL=$(gcloud config get-value core/account)
#gcloud config set compute/region us-central1
#gcloud config set compute/zone us-central1-a
#export ZONE=us-central1-a



#USER_EMAIL=$(gcloud auth list --limit=1 2>/dev/null | grep '@' | awk '{print $2}')
#----------------------------------------------------code--------------------------------------------------#

read -p "${BOLD}${YELLOW}Enter second Project ID : ${RESET}" SECOND_PROJECT_ID

echo "gcloud config set project $SECOND_PROJECT_ID
gcloud compute networks create network-b --subnet-mode custom
gcloud compute networks subnets create network-b-central --network network-b \
    --range 10.8.0.0/16 --region us-central1
gcloud compute instances create vm-b --zone us-central1-a --network network-b --subnet network-b-central
gcloud compute firewall-rules create network-b-fw --network network-b --allow tcp:22,icmp
tput bold;tput setaf 2; echo '

Task 2 Completed

'; tput sgr0; 
gcloud compute networks peerings create peer-ba --network=network-b --peer-project $PROJECT_ID --peer-network network-a
echo '  '
tput bold;tput setaf 2; echo Task 4 Completed ; tput sgr0; " > 2.sh

chmod +x 2.sh
echo "${BG_RED}${BOLD}

Run this in another terminal

./2.sh

${RESET}"

gcloud compute networks create network-a --subnet-mode custom
gcloud compute networks subnets create network-a-central --network network-a \
    --range 10.0.0.0/16 --region us-central1
gcloud compute instances create vm-a --zone us-central1-a --network network-a --subnet network-a-central
gcloud compute firewall-rules create network-a-fw --network network-a --allow tcp:22,icmp
echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"

gcloud compute networks peerings create peer-ab     --network=network-a     --peer-project $SECOND_PROJECT_ID     --peer-network network-b
echo "${GREEN}${BOLD}

Task 3 Completed

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
