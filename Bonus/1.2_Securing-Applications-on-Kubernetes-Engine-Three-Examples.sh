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
#export BUCKET_NAME=$(gcloud info --format='value(config.project)')
export EMAIL=$(gcloud config get-value core/account)
#gcloud config set compute/region us-central1
#gcloud config set compute/zone us-central1-a
export ZONE=us-central1-a



USER_EMAIL=$(gcloud auth list --limit=1 2>/dev/null | grep '@' | awk '{print $2}')
#----------------------------------------------------code--------------------------------------------------#
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a
git clone https://github.com/GoogleCloudPlatform/gke-security-scenarios-demo
cd gke-security-scenarios-demo
sed -i 's/f1-micro/n1-standard-1/g' ~/gke-security-scenarios-demo/terraform/variables.tf
make setup-project
cat terraform/terraform.tfvars
make create


echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"

cat > ssh.sh << EOF
kubectl get pods --all-namespaces
kubectl apply -f manifests/nginx.yaml
kubectl get pods
kubectl describe pod -l app=nginx

echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"

kubectl apply -f manifests/apparmor-loader.yaml
kubectl delete pods -l app=nginx
kubectl get pods
kubectl get services
echo "${GREEN}${BOLD}

Task 3 Completed

${RESET}"
kubectl get pods --show-labels
kubectl apply -f manifests/pod-labeler.yaml
kubectl get pods --show-labels

echo "${GREEN}${BOLD}

Task 4 Completed

${RESET}"
exit
EOF

chmod +x ssh.sh

set -x 
gcloud compute scp ssh.sh --zone=$ZONE --quiet  gke-tutorial-bastion:~
set +x
echo "${YELLOW}${BOLD}
Run this in ssh:
${BG_RED}
./ssh.sh

${RESET}"

gcloud compute ssh gke-tutorial-bastion --zone $ZONE --quiet


export PROJECT_ID=$(gcloud info --format='value(config.project)')
gcloud container clusters get-credentials gke-security-demo-ss --zone us-central1-a --project $PROJECT_ID
make teardown
echo "${GREEN}${BOLD}

Task 5 Completed

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
