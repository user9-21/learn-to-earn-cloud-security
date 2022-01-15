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
export ZONE=us-central1-a

#----------------------------------------------------code--------------------------------------------------#

gcloud container clusters get-credentials k8-cluster --zone us-central1-a --project $PROJECT_ID
curl https://storage.googleapis.com/qwiklabs-code/prisma_cloud_compute_edition_21_04_421.tar.gz -o prisma_cloud_compute_edition_21_04_421.tar.gz
mkdir prisma_cloud_compute_edition
tar xvzf prisma_cloud_compute_edition_21_04_421.tar.gz -C prisma_cloud_compute_edition/
cd prisma_cloud_compute_edition
./linux/twistcli console export kubernetes --service-type LoadBalancer
#token
kubectl create -f twistlock_console.yaml
kubectl get service -n twistlock | grep 'twistlock-console' |  awk '{print $4}'
TWISTLOCK_EXTERNAL_IP=$(kubectl get service -n twistlock | grep 'twistlock-console' |  awk '{print $4}')
echo $TWISTLOCK_EXTERNAL_IP
echo "${BG_RED}${BOLD}

Run this in another(+) terminal to get the  External IP (keep retrying until External IP Appears). 

kubectl get service -w -n twistlock

${RESET}"

read -p "${BOLD}${YELLOW}twistlock-console External IP Appeared?(y/n) : " TWISTLOCK_EXTERNAL_IP_APPEARED && echo "${RESET}"

while [ $TWISTLOCK_EXTERNAL_IP_APPEARED = n ];
do sleep 10 && TWISTLOCK_EXTERNAL_IP=$(kubectl get service -n twistlock | grep 'twistlock-console' |  awk '{print $4}') && echo $TWISTLOCK_EXTERNAL_IP && read -p "${BOLD}${YELLOW}twistlock-console External IP Appeared?(y/n) : " TWISTLOCK_EXTERNAL_IP_APPEARED && echo "${RESET}" ;
done

echo "${BOLD}${YELLOW}

Go to ${CYAN}https://$TWISTLOCK_EXTERNAL_IP:8083${RESET}${BOLD}${YELLOW}

and do manually as instructed from Qwiklabs start page

${RESET}"


read -p "${BOLD}${YELLOW}Done with Manual step?(y/n) : " DONE_WITH_MANUAL && echo "${RESET}"

while [ $DONE_WITH_MANUAL = n ];
do sleep 20 && read -p "${BOLD}${YELLOW}Done with Manual step?(y/n) : " DONE_WITH_MANUAL && echo "${RESET}"
done

git clone https://github.com/PaloAltoNetworks/prisma_cloud; cd prisma_cloud
kubectl create namespace sock-shop
kubectl apply -f sock-shop.yaml
kubectl get pods -o wide -n sock-shop
kubectl get service -n sock-shop

echo "${BG_YELLOW}${BOLD}

keep trying until front-end External IP Appears(in another(+) terminal). 

kubectl get service -n sock-shop

${RESET}"

FRONTEND_EXTERNAL_IP=$(kubectl get service -n sock-shop | grep 'front-end' |  awk '{print $4}')
echo $FRONTEND_EXTERNAL_IP


while [ $FRONTEND_EXTERNAL_IP = <pending> ];
do sleep 10 && FRONTEND_EXTERNAL_IP=$(kubectl get service -n sock-shop | grep 'front-end' |  awk '{print $4}') && echo $FRONTEND_EXTERNAL_IP ;
done


read -p "${BOLD}${YELLOW}front-end External IP Appeared?(y/n) : " FRONTEND_EXTERNAL_IP_APPEARED && echo "${RESET}"



cat > reverse.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: shell-pod
  labels:
    app: shell
spec:
  containers:
  - name: shell
    image: danielma911/ncat:v1
    volumeMounts:
    - mountPath: /host
      name: hostvolume
    command: ["/bin/sh"]
    args: ["-c", "while true; do sleep 100000;done"]
  volumes:
  - name: hostvolume
    hostPath:
      path: /
      type: Directory
EOF
kubectl create -f reverse.yaml

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
