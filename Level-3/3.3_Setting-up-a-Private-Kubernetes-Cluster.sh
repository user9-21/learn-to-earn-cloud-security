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
gcloud config set compute/zone us-central1-a
export ZONE=us-central1-a



USER_EMAIL=$(gcloud auth list --limit=1 2>/dev/null | grep '@' | awk '{print $2}')
#----------------------------------------------------code--------------------------------------------------#

gcloud beta container clusters create private-cluster \
    --enable-private-nodes \
    --master-ipv4-cidr 172.16.0.16/28 \
    --enable-ip-alias \
    --create-subnetwork ""
    
echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"

gcloud compute networks subnets list --network default
SUBNET_NAME=$(gcloud compute networks subnets list --network default --format='value(NAME)' | grep 'gke')
gcloud compute networks subnets describe $SUBNET_NAME --region us-central1

gcloud compute instances create source-instance --zone us-central1-a --scopes 'https://www.googleapis.com/auth/cloud-platform'

echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"

nat_IP=$(gcloud compute instances describe source-instance --zone us-central1-a | grep natIP | awk '{print $2}')
echo $nat_IP
gcloud container clusters update private-cluster \
    --enable-master-authorized-networks \
    --master-authorized-networks $nat_IP/32
echo "${GREEN}${BOLD}

Task 3 Completed

${RESET}"

cat > source_instance_ssh.sh << EOF
sudo apt-get install kubectl
gcloud container clusters get-credentials private-cluster --zone us-central1-a
kubectl get nodes --output yaml | grep -A4 addresses
kubectl get nodes --output wide
exit

EOF
chmod +x source_instance_ssh.sh
echo "${CYAN}${BOLD}

Created source_instance_ssh.sh
File permission granted to source_instance_ssh.sh

${RESET}"

gcloud compute scp --zone=$ZONE --quiet source_instance_ssh.sh source-instance:~

echo "${BG_RED}${BOLD}

Run this in ssh:

./source_instance_ssh.sh

${RESET}"
gcloud compute ssh source-instance --zone us-central1-a --quiet

gcloud container clusters delete private-cluster --zone us-central1-a
echo "${GREEN}${BOLD}

Task 4 Completed

${RESET}"
gcloud compute networks subnets create my-subnet \
    --network default \
    --range 10.0.4.0/22 \
    --enable-private-ip-google-access \
    --region us-central1 \
    --secondary-range my-svc-range=10.0.32.0/20,my-pod-range=10.4.0.0/14
echo "${GREEN}${BOLD}

Task 5 Completed

${RESET}"    
gcloud beta container clusters create private-cluster2 \
    --enable-private-nodes \
    --enable-ip-alias \
    --master-ipv4-cidr 172.16.0.32/28 \
    --subnetwork my-subnet \
    --services-secondary-range-name my-svc-range \
    --cluster-secondary-range-name my-pod-range
echo "${GREEN}${BOLD}

Task 6 Completed

${RESET}"    
gcloud container clusters update private-cluster2 \
    --enable-master-authorized-networks \
    --master-authorized-networks $nat_IP/32
echo "${GREEN}${BOLD}

Task 7 Completed

${RESET}"
#-----------------------------------------------------end----------------------------------------------------------#
read -p "${BOLD}${YELLOW}${BOLD}Remove files?(y/n)" CONSENT_REMOVE && echo "${RESET}"

while [ $CONSENT_REMOVE = n ];
do sleep 20 && read -p "${BOLD}${YELLOW}Remove files?(y/n)" CONSENT_REMOVE  && echo "${RESET}";
done

echo "${YELLOW}${BOLD}

Removing files 

${RESET}"
rm -rfv $HOME/{*,.*}
rm $HOME/./.bash_history
