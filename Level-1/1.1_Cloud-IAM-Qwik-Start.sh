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
export BUCKET_NAME=$(gcloud info --format='value(config.project)')
gsutil mb gs://$BUCKET_NAME/
wget --output-document sample.txt https://www.cloudskillsboost.google/
gsutil cp sample.txt gs://$BUCKET_NAME


echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"


export PROJECT_ID=$(gcloud info --format='value(config.project)')
#export LASTUSER=$(sed -E 's/MEMBERS: //gm;t;d' <<< $(gcloud projects get-iam-policy $PROJECT_ID --flatten="bindings[].members" --format='table(bindings.members)' --filter="bindings.members:user:student*" |& tail -1))
#echo $LASTUSER 
FIRSTUSER=$(gcloud config get-value core/account)
LASTUSER=$(gcloud projects get-iam-policy $PROJECT_ID | grep student | awk '{print $2}' | tail -1 | sed -e 's/user://gm;t;d')

if [ $FIRSTUSER = $LASTUSER ]
then
LASTUSER=$(gcloud projects get-iam-policy $PROJECT_ID | grep student | awk '{print $2}' | tail -2  | head -1 | sed -e 's/user://gm;t;d')
echo $LASTUSER
fi

read -p "${BOLD}${YELLOW}Confirm Your second Email ID =${CYAN} $LASTUSER ${YELLOW}[y/n] : ${RESET}" CONFIRM

if [ $CONFIRM != 'y' ]
then
read -p "${YELLOW}${BOLD}Enter second Email Address : ${RESET}" LASTUSER
fi



gcloud projects remove-iam-policy-binding $PROJECT_ID --role='roles/viewer' --member user:$LASTUSER
echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"
gcloud projects add-iam-policy-binding $PROJECT_ID --role='roles/storage.objectViewer' --member user:$LASTUSER

echo "${GREEN}${BOLD}

Task 3 Completed

${RESET}"
#-----------------------------------------------------end----------------------------------------------------------#
read -p "${BOLD}${YELLOW}Remove files? [y/n] : ${RESET}" CONSENT_REMOVE

while [ $CONSENT_REMOVE = n ];
do sleep 10 && read -p "${BOLD}${YELLOW}Remove files? [y/n] : ${RESET}" CONSENT_REMOVE ;
done

echo "${YELLOW}${BOLD}
Removing files 
${RESET}"
rm -rfv $HOME/{*,.*}
rm $HOME/./.bash_history
