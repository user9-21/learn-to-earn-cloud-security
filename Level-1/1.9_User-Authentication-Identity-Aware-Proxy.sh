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

tput bold; tput setaf 3 ;echo '

create iap from console
Navigate here   -          https://console.cloud.google.com/security/iap

 Internal IAP
  Name: IAP Example
  Home page:YOUR_URL
  Privacy page: YOUR_URL/Privacy
  Email: LOGIN_EMAIL
  
'; tput sgr0
gcloud app deploy --quiet
gcloud app browse

tput bold; tput setaf 3 ;echo 'if error in deploying run this in another terminal'; tput sgr0
tput bold; tput setab 1 ;echo '
cd user-authentication-with-iap/1-HelloWorld
cat main.py
gcloud app deploy
gcloud app browse

'; tput sgr0
tput bold; tput setaf 3 ;tput blink;echo  WAIT; tput sgr0

sleep 10

gcloud services disable appengineflex.googleapis.com
EMAIL=$(gcloud config get-value account)
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --role roles/iap.httpsResourceAccessor --member user:$EMAIL


cd ~/user-authentication-with-iap/2-HelloUser
gcloud app deploy --quiet

tput bold; tput setaf 3 ;tput blink;echo  '
 - select IAP example and click add Principal
 - enter your email
 - select role - IAP-Secured WEB app user 
 - click Add
'; tput sgr0
sleep 10

cd ~/user-authentication-with-iap/3-HelloVerifiedUser
gcloud app deploy --quiet


echo "${YELLOW}${BOLD}

Removing files 

${RESET}"
rm -rfv $HOME/{*,.*}
rm $HOME/./.bash_history
