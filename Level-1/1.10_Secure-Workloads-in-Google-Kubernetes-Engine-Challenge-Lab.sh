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
#----------------------------------------------------code--------------------------------------------------#
echo " "
read -p "${BOLD}${YELLOW}Enter Cluster name : ${RESET}" CLUSTER_NAME
read -p "${BOLD}${YELLOW}Enter Cloud SQL Instance : ${RESET}" SQL_INSTANCE
read -p "${BOLD}${YELLOW}Enter Service Account : ${RESET}" SERVICE_ACCOUNT
echo "${BOLD} "
echo "${YELLOW}Your Cluster name : ${CYAN}$CLUSTER_NAME  "
echo "${YELLOW}Your Cloud SQL Instance : ${CYAN}$SQL_INSTANCE  "
echo "${YELLOW}Your Service Account : ${CYAN}$SERVICE_ACCOUNT  ${RESET}"
echo " "

read -p "${BOLD}${YELLOW}Verify all details are correct? [y/n] : ${RESET}" VERIFY_DETAILS


while [ $VERIFY_DETAILS != 'y' ];
do echo " " && read -p "${BOLD}${YELLOW}Enter Cluster name : ${RESET}" CLUSTER_NAME && read -p "${BOLD}${YELLOW}Enter Cloud SQL Instance : ${RESET}" SQL_INSTANCE && read -p "${BOLD}${YELLOW}Enter Service Account : ${RESET}" SERVICE_ACCOUNT && echo "${BOLD} " && echo "${YELLOW}Your Cluster name : ${CYAN}$CLUSTER_NAME" && echo "${YELLOW}Your Cloud SQL Instance : ${CYAN}$SQL_INSTANCE" && echo "${YELLOW}Your Service Account : ${CYAN}$SERVICE_ACCOUNT ${RESET}" && echo " " && read -p "${BOLD}${YELLOW}Verify all details are correct? [y/n] : ${RESET}" VERIFY_DETAILS ;
done

echo "${BG_RED}${BOLD}

while Cluster is creating, Run this in another(+) terminal it will also take some time


gcloud sql instances create $SQL_INSTANCE --region us-central1

${RESET}"

gsutil cp gs://spls/gsp335/gsp335.zip .
unzip gsp335.zip


gcloud container clusters create $CLUSTER_NAME \
   --zone us-central1-c \
   --machine-type n1-standard-4 \
   --num-nodes 2 \
   --enable-network-policy
   
echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"
   
gcloud sql instances create $SQL_INSTANCE --region us-central1


read -p "${BOLD}${YELLOW}SQL Instance created? [y/n]: ${RESET}" VERIFY_SQL_INSTANCE
while [ $VERIFY_SQL_INSTANCE != 'y' ];
do sleep 10 && read -p "${BOLD}${YELLOW}SQL Instance created? [y/n]: ${RESET}" VERIFY_SQL_INSTANCE ;
done

echo "${BOLD}${YELLOW}

Create database 'wordpress' in sql instance manually here:- ${CYAN}https://console.cloud.google.com/sql/instances/$SQL_INSTANCE/databases?project=$PROJECT_ID

${RESET}"
gcloud sql users create wordpress --instance $SQL_INSTANCE --host %

read -p "${BOLD}${YELLOW}Created Database 'wordpress' ? [y/n]: ${RESET}" CREATED_DATABASE

while [ $CREATED_DATABASE != 'y' ];
do sleep 10 && read -p "${BOLD}${YELLOW}Created Database 'wordpress' ? [y/n]: ${RESET}" CREATED_DATABASE ;
done


echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"
gcloud iam service-accounts create $SERVICE_ACCOUNT
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" --role="roles/cloudsql.client"
gcloud iam service-accounts keys create key.json --iam-account=$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com

kubectl create secret generic cloudsql-instance-credentials --from-file key.json
kubectl create secret generic cloudsql-db-credentials \
   --from-literal username=wordpress \
   --from-literal password=''

echo "${GREEN}${BOLD}

Task 3 Completed

${RESET}"

echo "${GREEN}"

kubectl create -f volume.yaml
sed -i "s#INSTANCE_CONNECTION_NAME#$DEVSHELL_PROJECT_ID:us-central1:$SQL_INSTANCE#g" wordpress.yaml

sleep 2
kubectl apply -f wordpress.yaml
helm version
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm install nginx-ingress stable/nginx-ingress --set rbac.create=true
kubectl get service
kubectl get svc | grep nginx-ingress-controller | awk '{print $4}'
LOADBALANCER_EXTERNAL_IP=$(kubectl get svc | grep nginx-ingress-controller | awk '{print $4}')
echo $LOADBALANCER_EXTERNAL_IP

while [ $LOADBALANCER_EXTERNAL_IP = '<pending>' ];
do sleep 2 && LOADBALANCER_EXTERNAL_IP=$(kubectl get svc | grep nginx-ingress-controller | awk '{print $4}') && echo $LOADBALANCER_EXTERNAL_IP ;
done

. add_ip.sh  
echo "

"
read -p "${YELLOW}${BOLD}Your DNS Record(from above command) : ${RESET}" DNS_RECORD

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.16.0/cert-manager.yaml

export EMAIL=$(gcloud config get-value core/account)
echo "${CYAN}${BOLD}EMAIL = $EMAIL${RESET}"
kubectl create clusterrolebinding cluster-admin-binding \
   --clusterrole=cluster-admin \
   --user=$(gcloud config get-value core/account)


sed -i "s#LAB_EMAIL_ADDRESS#$EMAIL#g" issuer.yaml
sed -i "s#HOST_NAME#$DNS_RECORD#g" ingress.yaml
curl -o network-policy.yaml https://raw.githubusercontent.com/user9-21/learn-to-earn-cloud-security/main/files/network-policy.yaml
kubectl apply -f issuer.yaml
kubectl apply -f ingress.yaml
kubectl apply -f network-policy.yaml
gcloud services enable binaryauthorization.googleapis.com

#kubectl create -f volume.yaml

#kubectl apply -f wordpress.yaml
#kubectl apply -f issuer.yaml
#kubectl apply -f ingress.yaml
#kubectl apply -f network-policy.yaml

echo "${GREEN}${BOLD}

Task 4 Completed

${RESET}"
echo "${GREEN}${BOLD}

Task 5 Completed

${RESET}"

echo "${BOLD}${YELLOW}

Visit here and Setup Binary Authorization manually - ${CYAN}https://console.cloud.google.com/security/binary-authorization/start${YELLOW}

                                                   OR                                              

https://console.cloud.google.com/security/binary-authorization/policy/edit?project=$PROJECT_ID

  ==> In Default rule, Select ${CYAN}Disallow all images: Blocks all images from deployment. ${YELLOW}
  
  ==> In Specific rules, Select ${CYAN}GKE Cluster${YELLOW} as specific rule type.
      Click Add Specipic rule, Type u in GKE Cluster resource ID box and select the option ${CYAN}( format: 'location.cluster-id')${YELLOW} and click Add.
      
  ==> In Images exempt from this policy section, Click ${CYAN}Custom exemption rules${YELLOW} and add the following :- ${CYAN}
         docker.io/library/wordpress:latest
         us.gcr.io/k8s-artifacts-prod/ingress-nginx/*
         gcr.io/cloudsql-docker/*
         quay.io/jetstack/*${YELLOW}
         
   ==> Now Save Policy.

  "

echo " Go here ${CYAN}https://console.cloud.google.com/kubernetes/clusters/details/us-central1-c/$CLUSTER_NAME/details ${YELLOW}and Enable Binary authorization in security section of cluster.

         ${RESET}"

kubectl apply -f psp-restrictive.yaml
kubectl apply -f psp-role.yaml
kubectl apply -f psp-use.yaml

read -p "${BOLD}${YELLOW}Done with Manual step? [y/n]: ${RESET}" CONSENT_DONE

while [ $CONSENT_DONE != 'y' ];
do sleep 10 && read -p "${BOLD}${YELLOW}Done with Manual step? [y/n]: ${RESET}" CONSENT_DONE ;
done
echo "${GREEN}${BOLD}

Task 6 Completed

${RESET}"
echo "${GREEN}${BOLD}

Task 7 Completed

${RESET}"
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
exit
