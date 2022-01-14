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
gsutil cp gs://spls/gsp493/gke-rbac-demo.tar .
tar -xvf gke-rbac-demo.tar
make create
echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"
gcloud iam service-accounts list
gcloud compute instances list


echo "${BOLD}${YELLOW}

Open another(+) terminal and run this:
${RESET}${BOLD}${BG_RED}
gcloud compute ssh gke-tutorial-owner --zone $ZONE --quiet
${RESET}${BOLD}${YELLOW}
Open one another(+) terminal and run this:${RESET}
${RESET}${BOLD}${BG_RED}
gcloud compute ssh gke-tutorial-auditor --zone $ZONE --quiet

${RESET}"

read -p "${BOLD}${YELLOW}Done with above step?(y/n)" CONSENT_PROCEED && echo "${RESET}"

while [ $CONSENT_PROCEED = n ];
do sleep 5 && echo "${BOLD}${YELLOW}

Open another(+) terminal and run this:
${RESET}${BOLD}${BG_RED}
gcloud compute ssh gke-tutorial-owner --zone $ZONE --quiet
${RESET}${BOLD}${YELLOW}
Open one another(+) terminal and run this:${RESET}
${RESET}${BOLD}${BG_RED}
gcloud compute ssh gke-tutorial-auditor --zone $ZONE --quiet

${RESET}" && read -p "${BOLD}${YELLOW}Done with above step?(y/n)"  CONSENT_PROCEED  && echo "${RESET}";
done


cat > owner_instance_ssh.sh << EOF
kubectl create -n dev -f ./manifests/hello-server.yaml
kubectl create -n prod -f ./manifests/hello-server.yaml
kubectl create -n test -f ./manifests/hello-server.yaml
echo "${GREEN}${BOLD}

Task 3 Completed

${RESET}"

kubectl get pods -l app=hello-server --all-namespaces
exit  
EOF

chmod +x owner_instance_ssh.sh
echo "${CYAN}${BOLD}

created owner_instance_ssh
File permission granted to owner_instance_ssh

${RESET}"

gcloud compute scp --zone=$ZONE --quiet owner_instance_ssh.sh  gke-tutorial-owner:~


cat > auditor_instance_ssh.sh << EOF
kubectl get pods -l app=hello-server --all-namespaces
kubectl get pods -l app=hello-server --namespace=dev
kubectl get pods -l app=hello-server --namespace=test
kubectl get pods -l app=hello-server --namespace=prod
kubectl create -n dev -f manifests/hello-server.yaml
kubectl delete deployment -n dev -l app=hello-server
exit
EOF

chmod +x auditor_instance_ssh.sh
echo "${CYAN}${BOLD}

created auditor_instance_ssh
File permission granted to auditor_instance_ssh

${RESET}"

gcloud compute scp --zone=$ZONE --quiet auditor_instance_ssh.sh  gke-tutorial-auditor:~



cat > admin_instance_ssh.sh << EOF

kubectl apply -f ./manifests/rbac.yaml

echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"

kubectl apply -f manifests/pod-labeler.yaml

echo "${GREEN}${BOLD}

Task 4 Completed

${RESET}"
kubectl get pods -l app=pod-labeler
kubectl describe pod -l app=pod-labeler | tail -n 20
kubectl logs -l app=pod-labeler
kubectl get pod -oyaml -l app=pod-labeler
kubectl apply -f manifests/pod-labeler-fix-1.yaml
kubectl get deployment pod-labeler -oyaml

echo "${GREEN}${BOLD}

Task 5 Completed

${RESET}"


kubectl get pods -l app=pod-labeler
kubectl logs -l app=pod-labeler
kubectl get rolebinding pod-labeler -oyaml
kubectl get role pod-labeler -oyaml
kubectl apply -f manifests/pod-labeler-fix-2.yaml
echo "${GREEN}${BOLD}

Task 6 Completed

${RESET}"

kubectl get role pod-labeler -oyaml
kubectl delete pod -l app=pod-labeler
kubectl get pods --show-labels
kubectl logs -l app=pod-labeler
exit
EOF

chmod +x admin_instance_ssh.sh
echo "${CYAN}${BOLD}

created admin_instance_ssh
File permission granted to admin_instance_ssh

${RESET}"

gcloud compute scp --zone=$ZONE --quiet admin_instance_ssh.sh  gke-tutorial-admin:~

echo "${BG_RED}${BOLD}

Run this in ADMIN instance ssh:

./admin_instance_ssh.sh


${RESET}"

echo "${BG_RED}${BOLD}

Run this in OWNER instance ssh:

./owner_instance_ssh.sh

${RESET}"

echo "${BG_RED}${BOLD}

Run this in AUDITOR instance ssh:

./auditor_instance_ssh.sh


${RESET}"



gcloud compute ssh gke-tutorial-admin --zone $ZONE --quiet
make teardown

echo "${GREEN}${BOLD}

Task 7 Completed

${RESET}"




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
