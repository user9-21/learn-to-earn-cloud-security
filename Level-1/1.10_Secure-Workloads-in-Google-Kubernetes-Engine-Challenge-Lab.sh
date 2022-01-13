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
read -p "Your Cluster name:" CLUSTER_NAME
read -p "Your Cloud SQL Instance:" SQL_INSTANCE
read -p "Your Service Account:" SERVICE_ACCOUNT
echo " "
echo "Your Cluster name : $CLUSTER_NAME"
echo "Your Cloud SQL Instance : $SQL_INSTANCE"
echo "Your Service Account : $SERVICE_ACCOUNT"

read -p "Verify all details are correct?(y/n):" VERIFY_DETAILS

while [ $VERIFY_DETAILS = n ];
do read -p "Your Cluster name:" CLUSTER_NAME && read -p "Your Cloud SQL Instance:" SQL_INSTANCE && read -p "Your Service Account:" SERVICE_ACCOUNT && echo "Your Cluster name : $CLUSTER_NAME" && echo "Your Cloud SQL Instance : $SQL_INSTANCE" && echo "Your Service Account : $SERVICE_ACCOUNT" && read -p "Verify all details are correct?(y/n):" VERIFY_DETAILS ;
done

gsutil cp gs://spls/gsp335/gsp335.zip .
unzip gsp335.zip

echo "${BG_RED}${BOLD}

while Cluster is creating, Run this in another(+) terminal


gcloud sql instances create $SQL_INSTANCE --region us-central1

${RESET}"
gcloud container clusters create $CLUSTER_NAME \
   --zone us-central1-c \
   --machine-type n1-standard-4 \
   --num-nodes 2 \
   --enable-network-policy
   
gcloud sql instances create $SQL_INSTANCE --region us-central1
gcloud sql users create wordpress --instance $SQL_INSTANCE --host %

gcloud iam service-accounts create $SERVICE_ACCOUNT
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" --role="roles/cloudsql.client"
gcloud iam service-accounts keys create key.json --iam-account=$SERVICE_ACCOUNT@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com

kubectl create secret generic cloudsql-instance-credentials --from-file key.json
kubectl create secret generic cloudsql-db-credentials \
   --from-literal username=wordpress \
   --from-literal password=''
sed -i s#INSTANCE_CONNECTION_NAME#$DEVSHELL_PROJECT_ID:us-central1:$SQL_INSTANCE#g wordpress.yaml

helm version
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm install nginx-ingress stable/nginx-ingress --set rbac.create=true
kubectl get service
sleep 5
read -p "External IP Appeared ? (y/n):" EXTERNAL_IP_APPEARED

while [ $EXTERNAL_IP_APPEARED = n ];
do sleep 10 && kubectl get service && read -p "External IP Appeared ? (y/n):" EXTERNAL_IP_APPEARED ;
done

. add_ip.sh  
read -p "Your DNS Record(from above command):" DNS_RECORD


sed -i s#INSTANCE_CONNECTION_NAME#$EMAIL#g issuer.yaml
sed -i s#INSTANCE_CONNECTION_NAME#$DNS_RECORD#g ingress.yaml

curl -o network-policy.yaml 
kubectl apply -f network-policy.yaml

#-----------------------------------------------------end----------------------------------------------------------#
echo "${YELLOW}${BOLD}

Removing files 

${RESET}"
rm -rfv $HOME/{*,.*}
rm $HOME/./.bash_history
