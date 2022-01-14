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
#-------------------------------------------------code-------------------------------------------------# 

echo "${YELLOW}${BOLD}

Starting Execution 

${RESET}"

gsutil cp gs://spls/gsp499/user-authentication-with-iap.zip .
unzip user-authentication-with-iap.zip
cd user-authentication-with-iap
cd 1-HelloWorld
cat main.py
gcloud services enable iap.googleapis.com

echo "${YELLOW}${BOLD}

create iap from console

Navigate here   -          https://console.cloud.google.com/security/iap

 Internal IAP
  Name: IAP Example
  Home page:YOUR_URL
  Privacy page: YOUR_URL/Privacy
  Email: LOGIN_EMAIL
  
${RESET}"
gcloud app create --region "us-central"
gcloud app deploy --quiet
gcloud app browse

YOUR_URL=$(gcloud app browse | grep 'https')
echo "${YELLOW}${BOLD}

create iap from console

Navigate here   -          https://console.cloud.google.com/security/iap

 Internal IAP
 
  Name          :  IAP Example
  Home page     :  $YOUR_URL
  Privacy page  :  $YOUR_URL/Privacy
  Email         :  $EMAIL
  
${RESET}"

tput bold; tput setaf 3 ;tput blink;echo  WAIT; tput sgr0

gcloud services disable appengineflex.googleapis.com
EMAIL=$(gcloud config get-value account)
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --role roles/iap.httpsResourceAccessor --member user:$EMAIL


cd ~/user-authentication-with-iap/2-HelloUser
gcloud app deploy --quiet

echo "${YELLOW}${BOLD}

 - select IAP example and click add Principal
 - enter your email
 - select role - IAP-Secured WEB app user 
 - click Add
${RESET}"


cd ~/user-authentication-with-iap/3-HelloVerifiedUser
gcloud app deploy --quiet

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
