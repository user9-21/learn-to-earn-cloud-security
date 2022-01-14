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
gcloud config set compute/region us-central1
#gcloud config set compute/zone us-central1-a
export ZONE=us-central1-a



USER_EMAIL=$(gcloud auth list --limit=1 2>/dev/null | grep '@' | awk '{print $2}')
#----------------------------------------------------code--------------------------------------------------#


echo "${BOLD}${YELLOW}

Provision a domain

Visit Here :- https://console.cloud.google.com/marketplace/config/click-to-deploy-images/msad

and Add a Domain DNSName :- gcpnext.com
and create.

######### Do it Manually ###########
${RESET}"
read -p "${BOLD}${YELLOW}DONE as mentioned above? (y/n) : " DONE && echo "${RESET}"
while [ $DONE = n ];
do sleep 5 && read -p "${BOLD}${YELLOW}DONE as mentioned above? (y/n) : " DONE && echo "${RESET}" ;
done


gcloud compute instances create instance-1 --project=$DEVSHELL_PROJECT_ID --zone=us-central1-a --machine-type=n1-standard-2 --network-interface=network-tier=PREMIUM,private-network-ip=10.0.0.3,subnet=msad-1-sub0  --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=msad-1-tcp-3389,http-server,https-server --create-disk=auto-delete=yes,boot=yes,device-name=instance-1,image=projects/windows-cloud/global/images/windows-server-2019-dc-v20211216,mode=rw,size=50,type=projects/$DEVSHELL_PROJECT_ID/zones/us-central1-a/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

echo "${BOLD}${YELLOW}

Allow HTTP Traffic & HTTPS Traffic by editing instance manually 

Here :- https://console.cloud.google.com/compute/instances 

${RESET}"

gcloud compute instances get-serial-port-output instance-1 --zone us-central1-a | grep "Instance setup finished"

echo "${BOLD}${YELLOW}

Output Sample:

------------------------------------------------------------
Instance setup finished. instance-1 is ready to use.
------------------------------------------------------------

${RESET}"
read -p "${BOLD}${YELLOW}Output came(as mentioned above)? (y/n) : " OUTPUT_TRUE && echo "${RESET}"
while [ $OUTPUT_TRUE = n ];
do sleep 20 && gcloud compute instances get-serial-port-output instance-1 --zone us-central1-a | grep "Instance setup finished" && read -p "${BOLD}${YELLOW}Output came(as mentioned above)? (y/n) : " OUTPUT_TRUE && echo "${RESET}" ;
done


gcloud compute reset-windows-password instance-1 --zone us-central1-a --user admin --quiet
gcloud compute reset-windows-password msad-1-ad-1 --zone us-central1-f --user admin -y

#-----------------------------------------------------end----------------------------------------------------------#
read -p "${BOLD}${YELLOW}Remove files?(y/n)" CONSENT_REMOVE && echo "${RESET}"

while [ $CONSENT_REMOVE = n ];
do sleep 20 && read -p "${BOLD}${YELLOW}Remove files?(y/n)" CONSENT_REMOVE  && echo "${RESET}";
done

echo "${YELLOW}${BOLD}

Removing files 

${RESET}"
rm -rfv $HOME/{*,.*}
rm $HOME/./.bash_history
