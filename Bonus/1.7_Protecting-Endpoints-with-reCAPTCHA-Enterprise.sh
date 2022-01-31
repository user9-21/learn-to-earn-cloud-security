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
#gcloud auth list
#gcloud config list project
export PROJECT_ID=$(gcloud info --format='value(config.project)')
#export BUCKET_NAME=$(gcloud info --format='value(config.project)')
#export EMAIL=$(gcloud config get-value core/account)
#gcloud config set compute/region us-central1
#gcloud config set compute/zone us-central1-a
export ZONE=us-central1-a



#USER_EMAIL=$(gcloud auth list --limit=1 2>/dev/null | grep '@' | awk '{print $2}')
#----------------------------------------------------code--------------------------------------------------#
gcloud alpha recaptcha keys create --web --display-name=test-key --integration-type=CHECKBOX --allow-all-domains

echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"

KEY=$(gcloud alpha recaptcha keys list --format='value(SITE_KEY)')
echo $KEY

cat > index.html << EOF
<html>
      <head>
        <title>reCAPTCHA demo: Simple page</title>
        <script src="https://www.google.com/recaptcha/enterprise.js" async defer></script>
      </head>
      <body>
        <form action="?" method="POST" enctype="multipart/form-data">
          <div class="g-recaptcha" id="div" data-sitekey="site_key"></div>
          <br/>
          <input type="submit" onclick="alert('Checkbox Submitted')" value="Submit">
        </form>
      </body>
</html>
EOF

sed -i "s/site_key/$KEY/g" index.html
export PROJECT=$(gcloud config get-value project)
export BUCKET_NAME=gs://$PROJECT-bucket
gsutil cp index.html $BUCKET_NAME
gsutil acl ch -u AllUsers:R $BUCKET_NAME/index.html
gsutil acl ch -u AllUsers:W $BUCKET_NAME
bucket=$(echo $BUCKET_NAME | cut -c 6-)
date=$(date +%s)
echo "${CYAN}"
echo https://storage.googleapis.com/$bucket/index.html?date=$date


echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"


#-----------------------------------------------------end----------------------------------------------------------#
read -p "${BOLD}${YELLOW}Remove files? [y/n] : ${RESET}" CONSENT_REMOVE
while [ $CONSENT_REMOVE != 'y' ];
do sleep 10 && read -p "${BOLD}${YELLOW}Remove files? [y/n] : ${RESET}" CONSENT_REMOVE ;
done

echo "${YELLOW}${BOLD}

Removing files 

${RESET}"
rm -rfv $HOME/{*,.*}
rm $HOME/./.bash_history
logout
exit
