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



echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"


gcloud config set compute/zone us-central1-a
gcloud compute instances create blue --zone=us-central1-a --machine-type=n1-standard-1 --network-interface=network-tier=PREMIUM,subnet=default --maintenance-policy=MIGRATE --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=web-server,http-server --create-disk=auto-delete=yes,boot=yes,device-name=blue,image=projects/debian-cloud/global/images/debian-10-buster-v20210916,mode=rw,size=10,type=projects/$GOOGLE_CLOUD_PROJECT/zones/us-east4-a/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any
gcloud compute instances create green  --zone=us-central1-a

cat > blue.sh <<EOF

tput bold; tput setaf 3 ;echo Now in blue instance ssh; tput sgr0;
sudo apt-get install nginx-light -y
sed -i 's/nginx/Blue server/g' /var/www/html/index.nginx-debian.html
cat /var/www/html/index.nginx-debian.html

tput bold; tput setaf 3 ;echo enter exit to exit from blue instance ssh; tput sgr0;
EOF

cat > green.sh <<EOF

tput bold; tput setaf 3 ;echo Now in green instance ssh; tput sgr0;
sudo apt-get install nginx-light -y
sed -i 's/nginx/green server/g' /var/www/html/index.nginx-debian.html
cat /var/www/html/index.nginx-debian.html

tput bold; tput setaf 3 ;echo enter exit to exit from green instance ssh; tput sgr0;
EOF
tput bold; tput setaf 3 ;echo file created
ls
chmod +x blue.sh
chmod +x green.sh
echo file permission granted;
gcloud compute scp blue.sh blue:~
gcloud compute scp green.sh green:~
echo file copied 
tput bold; tput setaf 3 ;echo Run this in blue instance; tput sgr0;
tput bold; tput setab 1 ;echo '
ls
./blue.sh

'; tput sgr0;
gcloud compute ssh blue --zone us-central1-a --quiet

tput bold; tput setaf 3 ;echo Back in cloudshell; tput sgr0;
tput bold; tput setaf 3 ;echo Run this in green instance; tput sgr0;
tput bold; tput setab 1 ;echo '
ls
./green.sh

'; tput sgr0;
gcloud compute ssh green  --zone us-central1-a --quiet

tput bold; tput setaf 3 ;echo Back in cloudshell; tput sgr0;

gcloud compute firewall-rules create allow-http-web-server --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80,icmp --source-ranges=0.0.0.0/0 --target-tags=web-server
gcloud compute instances create test-vm --machine-type=f1-micro --subnet=default --zone=us-central1-a

gcloud iam service-accounts create network-admin --display-name network-admin
export PROJECT=$(gcloud info --format='value(config.project)')
echo Wait
sleep 10
export SA_EMAIL=$(gcloud iam service-accounts list --filter="displayName:network-admin" --format='value(email)')
echo $SA_EMAIL
gcloud projects add-iam-policy-binding $PROJECT  --role roles/compute.admin  --member serviceAccount:$SA_EMAIL	
gcloud iam service-accounts keys create credentials.json   --iam-account $SA_EMAIL
echo Done
tput bold; tput setaf 3 ;echo if error in iam run this; tput sgr0;
tput bold; tput setab 1 ;echo '

gcloud iam service-accounts create network-admin --display-name network-admin
export PROJECT=$(gcloud info --format="value(config.project)")
export SA_EMAIL=$(gcloud iam service-accounts list --filter="displayName:network-admin" --format="value(email)")
echo $SA_EMAIL
gcloud projects add-iam-policy-binding $PROJECT  --role roles/compute.admin  --member serviceAccount:$SA_EMAIL	
gcloud iam service-accounts keys create credentials.json   --iam-account $SA_EMAIL

'; tput sgr0;









echo "${GREEN}${BOLD}

Task 2 Completed

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
