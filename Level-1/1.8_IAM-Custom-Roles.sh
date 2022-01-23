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
export EMAIL=$(gcloud config get-value core/account)
export ZONE=us-central1-a

#----------------------------------------------------code--------------------------------------------------#

cat > role-definition.yaml <<EOF
title: "Role Editor"
description: "Edit access for App Versions"
stage: "ALPHA"
includedPermissions:
- appengine.versions.create
- appengine.versions.delete
EOF

gcloud iam roles create editor --project $DEVSHELL_PROJECT_ID \
--file role-definition.yaml
echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"

gcloud iam roles create viewer --project $DEVSHELL_PROJECT_ID \
--title "Role Viewer" --description "Custom role description." \
--permissions compute.instances.get,compute.instances.list --stage ALPHA
echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"
gcloud iam roles list --project $DEVSHELL_PROJECT_ID

cat > new-role-definition.yaml <<EOF
title: "Role Editor"
description: "Edit access for App Versions"
stage: "ALPHA"
includedPermissions:
- appengine.versions.create
- appengine.versions.delete
- storage.buckets.get
- storage.buckets.list
EOF
gcloud iam roles update editor --project $DEVSHELL_PROJECT_ID \
--file new-role-definition.yaml
echo "${GREEN}${BOLD}

Task 3 Completed

${RESET}"
gcloud iam roles update viewer --project $DEVSHELL_PROJECT_ID \
--add-permissions storage.buckets.get,storage.buckets.list
echo "${GREEN}${BOLD}

Task 4 Completed

${RESET}"
gcloud iam roles update viewer --project $DEVSHELL_PROJECT_ID \
--stage DISABLED
echo "${GREEN}${BOLD}

Task 5 Completed

${RESET}"
gcloud iam roles delete viewer --project $DEVSHELL_PROJECT_ID
gcloud iam roles undelete viewer --project $DEVSHELL_PROJECT_ID
echo "${GREEN}${BOLD}

Task 6 Completed

${RESET}"

echo "${GREEN}${BOLD}

Game Completed

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
logout
