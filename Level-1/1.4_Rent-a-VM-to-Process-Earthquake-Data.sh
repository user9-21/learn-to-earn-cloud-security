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

echo "${YELLOW}${BOLD}

Starting Execution 

${RESET}"
GET_PROJECT_ID=$(gcloud projects list | grep 'PROJECT_ID: qwiklabs-gcp' | awk '{print $2}' | head -1)
gcloud config set project $GET_PROJECT_ID
export ZONE=us-central1-a
export BUCKET_NAME=$(gcloud info --format='value(config.project)')
gsutil mb gs://$BUCKET_NAME/
echo '#!/bin/bash
apt-get update
apt-get install -y -qq install git
apt-get -y install python-mpltoolkits.basemap' > resources-install-web.sh

gsutil  cp resources-install-web.sh gs://$BUCKET_NAME
gcloud compute instances create myinstance --project=$GOOGLE_CLOUD_PROJECT --zone=$ZONE --metadata=startup-script-url=gs://$BUCKET_NAME/resources-install-web.sh  --scopes=https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/devstorage.read_only

echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"
cat > ssh.sh <<EOF
sudo apt-get update
sudo apt-get -y -qq install git
sudo apt-get -y install python-mpltoolkits.basemap
git --version
echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"


#git clone https://github.com/GoogleCloudPlatform/training-data-analyst
#cd training-data-analyst/CPB100/lab2b
mkdir training-data-analyst
mkdir training-data-analyst/CPB100
mkdir training-data-analyst/CPB100/lab2b
cd training-data-analyst/CPB100/lab2b
curl -o ingest.sh https://raw.githubusercontent.com/GoogleCloudPlatform/training-data-analyst/master/CPB100/lab2b/ingest.sh
curl -o install_missing.sh https://raw.githubusercontent.com/GoogleCloudPlatform/training-data-analyst/master/CPB100/lab2b/install_missing.sh
curl -o transform.py https://raw.githubusercontent.com/GoogleCloudPlatform/training-data-analyst/master/CPB100/lab2b/transform.py
bash ingest.sh
echo "${GREEN}${BOLD}

Task 3 Completed

${RESET}"

bash install_missing.sh
python3 transform.py
ls -l
echo "${GREEN}${BOLD}

Task 4 Completed

${RESET}"

export BUCKET_NAME=$GOOGLE_CLOUD_PROJECT
gsutil cp earthquakes.* gs://$BUCKET_NAME/earthquakes/
echo "${GREEN}${BOLD}

Task 5 Completed

${RESET}"

gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/earthquakes/earthquakes.csv
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/earthquakes/earthquakes.png
logout
exit

EOF

chmod +x ssh.sh
echo "${CYAN}${BOLD}

File permission granted to ssh.sh

${RESET}"

gcloud compute scp --zone=$ZONE --quiet ssh.sh myinstance:~

echo "${BOLD}${YELLOW}

Run this in ssh:
${BG_RED}
./ssh.sh

${RESET}${BOLD}${YELLOW}

If file is not present in myinstance ssh, run this in another(+) terminal, then run the above command:
${BG_RED}
gcloud compute scp --zone=$ZONE --quiet ssh.sh myinstance:~
${RESET}"
gcloud compute scp --zone=$ZONE --quiet ssh.sh myinstance:~

gcloud compute ssh myinstance --zone=$ZONE --quiet


echo "${YELLOW}${BOLD}

Back IN shell 

${RESET}"


read -p "${BOLD}${YELLOW}Remove files? [y/n]: ${RESET}" CONSENT_REMOVE

while [ $CONSENT_REMOVE != 'y' ];
do sleep 10 && read -p "${BOLD}${YELLOW}Remove files? [y/n]: ${RESET}" CONSENT_REMOVE ;
done

echo "${YELLOW}${BOLD}
Removing files 
${RESET}"
rm -rfv $HOME/{*,.*}
rm $HOME/./.bash_history
