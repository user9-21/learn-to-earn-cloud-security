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

gsutil cp gs://spls/gsp499/user-authentication-with-iap.zip .
unzip user-authentication-with-iap.zip
cd user-authentication-with-iap
cd 1-HelloWorld
cat main.py
gcloud services enable iap.googleapis.com

echo "${YELLOW}${BOLD}

create IAP from console

Go here${CYAN} https://console.cloud.google.com/apis/credentials/consent/edit;newAppInternalUser=true?project=$PROJECT_ID ${YELLOW}and configure Internal IAP with the given credentials
 
  Name         : ${CYAN} IAP Example ${YELLOW}
  Home page    : ${CYAN} YOUR_APP_URL ${YELLOW}
  DOMAIN       : ${CYAN} YOUR_APP_URL ${YELLOW} ( Do not include the starting https:// or trailing / from that URL. )
  Email        : ${CYAN} LOGIN_EMAIL ${YELLOW}
  
   
 Click Save and Continue
${RESET}"
gcloud app create --region "us-central"
gcloud app deploy --quiet
gcloud app browse

echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --role roles/iap.httpsResourceAccessor --member user:$EMAIL

YOUR_URL=$(gcloud app browse | grep 'https')
echo " ${BOLD}${BG_YELLOW} 

Confirm your iap configuration has following credentials 
${RESET}${YELLOW}${BOLD}
Navigate here   -     ${CYAN}     https://console.cloud.google.com/security/iap?project=$PROJECT_ID ${YELLOW} 
 
  Name          : ${CYAN} IAP Example ${YELLOW} 
  Home page     : ${CYAN} $YOUR_URL ${YELLOW}
  DOMAIN        : ${CYAN} $YOUR_URL ${YELLOW} ( Do not include the starting https:// or trailing / from that URL. )
  Email         : ${CYAN} $EMAIL ${YELLOW}
  
 
${RESET}"

tput bold; tput setaf 3 ;tput blink;echo  WAIT; tput sgr0

gcloud services disable appengineflex.googleapis.com
EMAIL=$(gcloud config get-value account)

echo "${YELLOW}${BOLD}

Go here ${CYAN}https://console.cloud.google.com/security/iap?project=$PROJECT_ID ${YELLOW} and Turn on IAP by sliding the switch next to App Engine app

 - select App Engine app and click add Principal
 - enter your email : ${CYAN} $EMAIL ${YELLOW}
 - select role      : ${CYAN} IAP-Secured WEB app user ${YELLOW}
 - click Add
${RESET}"
echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"


cd ~/user-authentication-with-iap/2-HelloUser
gcloud app deploy --quiet
echo "${GREEN}${BOLD}

Task 3 Completed

${RESET}"


cd ~/user-authentication-with-iap/3-HelloVerifiedUser
gcloud app deploy --quiet
echo "${GREEN}${BOLD}

Task 4 Completed

${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#
read -p "${BOLD}${YELLOW}Remove files? [y/n]: ${RESET}" CONSENT_REMOVE

while [ $CONSENT_REMOVE != 'y' ];
do sleep 10 && read -p "${BOLD}${YELLOW}Remove files? [y/n]: ${RESET}" CONSENT_REMOVE ;
done

echo "${YELLOW}${BOLD}
Removing files 
${RESET}"
rm -rfv $HOME/{*,.*}
rm $HOME/./.bash_history
