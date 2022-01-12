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

echo "${YELLOW}${BOLD} Starting Execution ${RESET}"

export ZONE=us-central1-a
export BUCKET_NAME=$(gcloud info --format='value(config.project)')
gsutil mb gs://$BUCKET_NAME/
gcloud compute instances create myinstance --project=$GOOGLE_CLOUD_PROJECT --zone=$ZONE --scopes=https://www.googleapis.com/auth/cloud-platform 

cat > ssh.sh <<EOF
sudo apt-get update
sudo apt-get -y -qq install git
sudo apt-get install python-mpltoolkits.basemap --quiet
git --version

git clone https://github.com/GoogleCloudPlatform/training-data-analyst
cd training-data-analyst/CPB100/lab2b
bash ingest.sh
bash install_missing.sh
python3 transform.py
ls -l
export BUCKET_NAME=$GOOGLE_CLOUD_PROJECT
gsutil cp earthquakes.* gs://$BUCKET_NAME/earthquakes/
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/earthquakes.htm
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/earthquakes.png
EOF

chmod +x ssh.sh
echo "${CYAN}${BOLD} File permission granted ${RESET}"

gcloud compute scp ssh.sh myinstance:~
cat ssh.sh

echo "${BG_RED}${BOLD} Run this in ssh:

./ssh.sh

${RESET}"
gcloud compute ssh myinstance --zone=$ZONE --quiet


echo "${YELLOW}${BOLD} IN shell ${RESET}"
rm $HOME/./.bash_history
rm $HOME/./.bash_history.swp
rm $HOME
