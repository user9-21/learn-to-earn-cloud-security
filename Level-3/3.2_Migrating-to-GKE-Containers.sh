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

sudo apt-get update
sudo apt-get install apache2-utils -y
ab -V

git clone https://github.com/GoogleCloudPlatform/gke-migration-to-containers.git
cd gke-migration-to-containers
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a
sed -i "s/f1-micro/n1-standard-1/g" terraform/variables.tf
make create
echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"

cat > cos_vm_ssh.sh << EOF
git clone https://github.com/GoogleCloudPlatform/gke-migration-to-containers.git
cd gke-migration-to-containers/container
sudo docker build -t gcr.io/migration-to-containers/prime-flask:1.0.2 .
ps aux | grep 8080

read -p "${BOLD}${YELLOW}Enter the first 'chronos' port number(from above command output) : ${RESET}" PORT_NUMBER
sudo kill -9 $PORT_NUMBER
sudo docker run --rm -d --name=appuser -p 8080:8080 gcr.io/migration-to-containers/prime-flask:1.0.2
ps aux
ls /usr/local/bin/python
sudo docker ps
sudo docker exec -it $(sudo docker ps |awk '/prime-flask/ {print $1}') ps aux
exit

EOF

chmod +x cos_vm_ssh.sh
echo "${CYAN}${BOLD}

Created cos_vm_ssh.sh
File permission granted to cos_vm_ssh.sh

${RESET}"

gcloud compute scp --zone=$ZONE --quiet cos_vm_ssh.sh cos-vm:~

echo "${BG_RED}${BOLD}

Run this in cos-vm ssh:

./cos_vm_ssh.sh

${RESET}"

echo "${YELLOW}${BOLD}

If permission denied in running script file in ssh , run manually the commands shown below

${RESET}"

echo "${CYAN}${BOLD}"
echo '
git clone https://github.com/GoogleCloudPlatform/gke-migration-to-containers.git
cd gke-migration-to-containers/container
sudo docker build -t gcr.io/migration-to-containers/prime-flask:1.0.2 .
ps aux | grep 8080

read -p "${BOLD}${YELLOW}Enter the first 'chronos' port number(from above command output) : ${RESET}" PORT_NUMBER

sudo kill -9 $PORT_NUMBER
sudo docker run --rm -d --name=appuser -p 8080:8080 gcr.io/migration-to-containers/prime-flask:1.0.2
ps aux
ls /usr/local/bin/python
sudo docker ps
sudo docker exec -it $(sudo docker ps |awk '/prime-flask/ {print $1}') ps aux
exit

'
echo "${RESET}"

gcloud compute ssh cos-vm --zone us-central1-a --quiet

gcloud container clusters get-credentials prime-server-cluster
kubectl get pods
kubectl exec $(kubectl get pods -lapp=prime-server -ojsonpath='{.items[].metadata.name}')  -- ps aux
make validate



read -p "${BOLD}${YELLOW}Enter IP Address for Kubernetes Webapp(from above command output) : " IP_ADDRESS

echo "${BG_RED}${BOLD}

Run this in another(+) terminal:-

ab -c 120 -t 60  http://$IP_ADDRESS/prime/10000

${RESET}"

echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"

kubectl scale --replicas 3 deployment/prime-server

echo "${BG_RED}${BOLD}

Again Run this in another(+) terminal:-

ab -c 120 -t 60  http://$IP_ADDRESS/prime/10000

${RESET}"

echo "${GREEN}${BOLD}

Task 3 Completed

${RESET}"



#-----------------------------------------------------end----------------------------------------------------------#
read -p "${BOLD}${YELLOW}Remove files?(y/n)" CONSENT_REMOVE && echo "${RESET}"

while [ $CONSENT_REMOVE != 'y' ];
do sleep 20 && read -p "${BOLD}${YELLOW}Remove files?[y/n] : ${RESET}" CONSENT_REMOVE ;
done

echo "${YELLOW}${BOLD}

Removing files 

${RESET}"
rm -rfv $HOME/{*,.*}
rm $HOME/./.bash_history
