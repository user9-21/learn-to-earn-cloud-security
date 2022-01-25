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
export ZONE=us-central1-a



USER_EMAIL=$(gcloud auth list --limit=1 2>/dev/null | grep '@' | awk '{print $2}')
#----------------------------------------------------code--------------------------------------------------#

git clone https://github.com/GoogleCloudPlatform/gke-network-policy-demo.git
cd gke-network-policy-demo
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a

cat > bastion_ssh.sh << EOF
kubectl apply -f ./manifests/hello-app/
kubectl get pods

kubectl logs --tail 10 -f $(kubectl get pods -oname -l app=hello)
kubectl logs --tail 10 -f $(kubectl get pods -oname -l app=not-hello)
echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"
kubectl apply -f ./manifests/network-policy.yaml

kubectl logs --tail 10 -f $(kubectl get pods -oname -l app=not-hello)
kubectl delete -f ./manifests/network-policy.yaml
kubectl create -f ./manifests/network-policy-namespaced.yaml

kubectl logs --tail 10 -f $(kubectl get pods -oname -l app=hello)
kubectl -n hello-apps apply -f ./manifests/hello-app/hello-client.yaml

kubectl logs --tail 10 -f -n hello-apps $(kubectl get pods -oname -l app=hello -n hello-apps)
echo "${GREEN}${BOLD}

Task 3 Completed

${RESET}"
exit

EOF

chmod +x bastion_ssh.sh
echo "${CYAN}${BOLD}

File permission granted 

${RESET}"


make setup-project 





cat terraform/terraform.tfvars

sed -i 's/~> 2.17.0/~> 2.17.0/g' terraform/provider.tf

make tf-apply



gcloud container clusters describe gke-demo-cluster | grep  -A2 networkPolicy


echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"


cd $HOME
set -x
cd gke-network-policy-demo
gcloud compute scp --quiet bastion_ssh.sh --zone $ZONE gke-demo-bastion:~

set +x
echo "${BG_RED}${BOLD}

Run this in ssh:

./bastion_ssh.sh

${RESET}"

gcloud compute ssh gke-demo-bastion --quiet

make teardown


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
