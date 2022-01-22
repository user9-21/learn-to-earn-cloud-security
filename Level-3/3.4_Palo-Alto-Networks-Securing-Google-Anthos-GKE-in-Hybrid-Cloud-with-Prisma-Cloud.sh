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

gcloud services enable \
    cloudresourcemanager.googleapis.com \
    container.googleapis.com \
    gkeconnect.googleapis.com \
    gkehub.googleapis.com \
    serviceusage.googleapis.com \
    anthos.googleapis.com

gcloud projects add-iam-policy-binding $PROJECT_ID  --member="user:$EMAIL" --role="roles/storage.objectAdmin"
gcloud projects add-iam-policy-binding $PROJECT_ID  --member="user:$EMAIL" --role="roles/storage.objectViewer"
git clone -b workshop-v1 https://github.com/GoogleCloudPlatform/anthos-workshop.git anthos-workshop
cd anthos-workshop
source ./common/connect-kops-remote.sh

  
echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"


source ./common/connect-kops-remote.sh
export PROJECT=$(gcloud config get-value project)
export KOPS_STATE_STORE=gs://$DEVSHELL_PROJECT_ID-kops-remote
NAME=remote.k8s.local
kops export kubecfg ${NAME} --admin
kubectl get nodes
kops validate cluster --name remote.k8s.local --state gs://$PROJECT-kops-remote
KUBECOFIG= kubectl config view --minify --flatten --context=central > workdir/central.context
KUBECOFIG= kubectl config view --minify --flatten --context=remote.k8s.local > workdir/remote.context
export PROJECT=$(gcloud config get-value project)
export GKE_SA_CREDS=$WORK_DIR/anthos-connect-creds.json
#gcloud projects add-iam-policy-binding $PROJECT     --member="user:$EMAIL" --role="roles/storage.objectAdmin"
gcloud projects add-iam-policy-binding $PROJECT \
    --member="serviceAccount:$PROJECT@$PROJECT.iam.gserviceaccount.com" \
    --role="roles/gkehub.connect"
# gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$PROJECT@$PROJECT.iam.gserviceaccount.com" --role="roles/storage.objectAdmin"
gcloud iam service-accounts keys create $GKE_SA_CREDS \
  --iam-account=$PROJECT@$PROJECT.iam.gserviceaccount.com \
  --project=$PROJECT
  
export PROJECT=$(gcloud config get-value project)
cd ~/anthos-workshop
source ./common/connect-kops-remote.sh
export GKE_SA_CREDS=$WORK_DIR/anthos-connect-creds.json
gcloud container clusters get-credentials central --zone us-central1-b --project $PROJECT
export KOPS_STATE_STORE=gs://$DEVSHELL_PROJECT_ID-kops-remote
NAME=remote.k8s.local
kops export kubecfg ${NAME} --admin
gcloud container hub memberships register remote  --context=remote.k8s.local  --service-account-key-file=$GKE_SA_CREDS  --kubeconfig=workdir/remote.context --project=$PROJECT
echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"

export KOPS_STATE_STORE=gs://$DEVSHELL_PROJECT_ID-kops-remote
NAME=remote.k8s.local
kops export kubecfg ${NAME} --admin
export KSA=remote-admin-sa
kubectl create serviceaccount $KSA
kubectl create clusterrolebinding ksa-admin-binding \
    --clusterrole cluster-admin \
    --serviceaccount default:$KSA
printf "\n$(kubectl describe secret $KSA | sed -ne 's/^token: *//p')\n\n"

echo "${GREEN}${BOLD}

Task 3 Completed

${RESET}"
echo "${BOLD}${YELLOW}

In the Cloud Console go to Navigation menu > Kubernetes Engine > Clusters then open Kubernetes Clusters.
(https://console.cloud.google.com/kubernetes/list/overview)

 - Right click on the three dots of the remote cluster, select Login
 - Fill out Log in to cluster form.
 - Select Token as the authentication method
 - Paste the token value copied from the previous step to the Token field(select the token output by carefully selecting the text, without capturing any trailing spaces)
 - Click Login
 
 
Add metadata for the remote cluster

 - Click remote cluster.
 - Click on the pen sign next to Labels to add a key and value and click ADD LABEL.
 - Add 
      Key 1 : location        Value 1 : remote
      Key 2 : env             Value 2 : prod
 - Click Save. The Labels have been updated, and your updates are shown.
${RESET}"

read -p "${BOLD}${YELLOW}Done with above? [y/n] : ${RESET}" CONSENT_PROCEED 

while [ $CONSENT_PROCEED != 'y' ];
do sleep 20 && read -p "${BOLD}${YELLOW}Done with above? [y/n] : ${RESET}" CONSENT_PROCEED ;
done

echo "${GREEN}${BOLD}

Task 4 Completed

${RESET}"



gcloud container clusters get-credentials central --zone us-central1-b --project $DEVSHELL_PROJECT_ID
curl -O https://storage.googleapis.com/qwiklabs-code/prisma_cloud_compute_edition_21_04_421.tar.gz
mkdir prisma_cloud_compute_edition
tar xvzf prisma_cloud_compute_edition_21_04_421.tar.gz -C prisma_cloud_compute_edition/
cd prisma_cloud_compute_edition
echo "${YELLOW}${BOLD}Enter token from the Qwiklabs start page under Student Resources to create the Prisma Cloud Compute console${RESET}"
./linux/twistcli console export kubernetes --service-type LoadBalancer
kubectl create -f twistlock_console.yaml
kubectl get service -n twistlock | grep 'twistlock-console' |  awk '{print $4}'
TWISTLOCK_EXTERNAL_IP=$(kubectl get service -n twistlock | grep 'twistlock-console' |  awk '{print $4}')
echo $TWISTLOCK_EXTERNAL_IP
echo "${BOLD}${YELLOW}
Run this in another(+) terminal to get the  External IP (wait until External IP Appears).
${BG_RED}
kubectl get service -w -n twistlock

${RESET}"


while [ $TWISTLOCK_EXTERNAL_IP = '<pending>' ];
do sleep 10 && TWISTLOCK_EXTERNAL_IP=$(kubectl get service -n twistlock | grep 'twistlock-console' |  awk '{print $4}') && echo $TWISTLOCK_EXTERNAL_IP ;
done

kubectl get service -n twistlock | grep 'twistlock-console' |  awk '{print $4}'

echo "${BOLD}${YELLOW}

Go to ${CYAN}https://$TWISTLOCK_EXTERNAL_IP:8083${RESET}${BOLD}${YELLOW} and Install prisma Cloud Compute  as instructed from Qwiklabs start page

 
 PAste Defender install script in another terminal in order to successfully execute this script

${RESET}"

sleep 50



echo "${YELLOW}${BOLD}
 
### before executing kops command run this to configure kops environment ###


export PROJECT=$(gcloud config get-value project) 
cd ~/anthos-workshop 
source ./common/connect-kops-remote.sh 
export GKE_SA_CREDS=$WORK_DIR/anthos-connect-creds.json 
gcloud container clusters get-credentials central --zone us-central1-b --project $PROJECT 
export KOPS_STATE_STORE=gs://$DEVSHELL_PROJECT_ID-kops-remote 
NAME=remote.k8s.local 
kops export kubecfg ${NAME} --admin


${RESET}"

read -p "${BOLD}${YELLOW}Done with Manual step(Install Prisma Cloud Compute, Defenfder)? [y/n]: ${RESET}" CONSENT_PROCEED

while [ $CONSENT_PROCEED != 'y' ];
do sleep 20 && read -p "${BOLD}${YELLOW}Done with Manual step(Install Prisma Cloud Compute, Defenfder)? (y/n): " CONSENT_PROCEED && echo "${RESET}" ;
done

export KOPS_STATE_STORE=gs://$DEVSHELL_PROJECT_ID-kops-remote
NAME=remote.k8s.local
kops export kubecfg ${NAME} --admin

kubectl get services -A
kubectx central
kubectl get services -A

export KOPS_STATE_STORE=gs://$DEVSHELL_PROJECT_ID-kops-remote
NAME=remote.k8s.local
kops export kubecfg ${NAME} --admin
#-----------------------------------------------------end----------------------------------------------------------#
read -p "${BOLD}${YELLOW}Remove files? [y/n]: ${RESET}" CONSENT_REMOVE

while [ $CONSENT_REMOVE != 'y' ];
do sleep 20 && read -p "${BOLD}${YELLOW}Remove files? [y/n]: ${RESET}" CONSENT_REMOVE ;
done

echo "${YELLOW}${BOLD}

Removing files 

${RESET}"
rm -rfv $HOME/{*,.*}
rm $HOME/./.bash_history
