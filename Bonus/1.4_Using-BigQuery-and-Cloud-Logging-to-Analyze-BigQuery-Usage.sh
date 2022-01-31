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

bq mk bq_logs

echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"
bq query --use_legacy_sql=false \ 'SELECT current_date'
gcloud logging read 'resource.type="bigquery_resource" protoPayload.methodName="jobservice.jobcompleted"' --limit 20 --format json
gcloud logging read 'resource.type="bigquery_resource" protoPayload.methodName="jobservice.jobcompleted"' --limit 20 --format json
gcloud logging read 'resource.type="bigquery_resource" protoPayload.methodName="jobservice.jobcompleted"' --limit 20 --format json

gcloud logging sinks create JobComplete bigquery.googleapis.com/projects/$PROJECT_ID/datasets/bq_logs --log-filter='resource.type="bigquery_resource" protoPayload.methodName="jobservice.jobcompleted"' --quiet


echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"

bq query --location=us --use_legacy_sql=false --use_cache=false \
'SELECT fullName, AVG(CL.numberOfYears) avgyears
 FROM `bigquery-samples.nested.persons_living`, UNNEST(citiesLived) as CL
 GROUP BY fullname'
bq query --location=us --use_legacy_sql=false --use_cache=false \
'select month, avg(mean_temp) as avgtemp from `bigquery-samples.weather_geo.gsod`
 where station_number = 947680
 and year = 2010
 group by month
 order by month'
bq query --location=us --use_legacy_sql=false --use_cache=false \
'select CONCAT(departure_airport, "-", arrival_airport) as route, count(*) as numberflights
 from `bigquery-samples.airline_ontime_data.airline_id_codes` ac,
 `bigquery-samples.airline_ontime_data.flights` fl
 where ac.code = fl.airline_code
 and regexp_contains(ac.airline ,  r"Alaska")
 group by 1
 order by 2 desc
 LIMIT 10'

echo "${GREEN}${BOLD}

Task 3 Completed

${RESET}"


echo "
bq query --use_legacy_sql=false \ 'CREATE OR REPLACE VIEW
  bq_logs.v_querylogs AS
SELECT
  resource.labels.project_id,
  protopayload_auditlog.authenticationInfo.principalEmail,
  protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobConfiguration.query.query,
  protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobConfiguration.query.statementType,
  protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatus.error.message,
  protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.startTime,
  protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.endTime,
  TIMESTAMP_DIFF(protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.endTime,           protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.startTime, MILLISECOND)/1000 AS run_seconds,
  protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.totalProcessedBytes,
  protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.totalSlotMs,
  ARRAY(SELECT as STRUCT datasetid, tableId FROM UNNEST(protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.referencedTables)) as tables_ref,
  protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.totalTablesProcessed,
  protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.queryOutputRowCount,
  severity
FROM
  '$DEVSHELL_PROJECT_ID.bq_logs.cloudaudit_googleapis_com_data_access_*'
ORDER BY
  startTime
' " > query.sh
sed -i "s/'$DEVSHELL_PROJECT_ID.bq_logs.cloudaudit_googleapis_com_data_access_*'/`$DEVSHELL_PROJECT_ID.bq_logs.cloudaudit_googleapis_com_data_access_*`/g" query.sh
chmod +x query.sh
cat query.sh
./query.sh

echo "${GREEN}${BOLD}

Task 4 Completed.

Game completed.

${RESET}"
echo "${YELLOW}${BOLD}
If ${RED}error${YELLOW} occured , Do this: 


1. Delete JobComplete sink from ${CYAN}https://console.cloud.google.com/logs/router?project=$PROJECT_ID
${YELLOW}
2. Visit here -${CYAN} https://console.cloud.google.com/logs/query;query=resource.type%3D%22bigquery_resource%22%20protoPayload.methodName%3D%22jobservice.jobcompleted%22?project=$PROJECT_ID
${YELLOW}
3. Visit here -${CYAN}  https://console.cloud.google.com/logs/router/sink;query=resource.type%3D%22bigquery_resource%22%20protoPayload.methodName%3D%22jobservice.jobcompleted%22?project=$PROJECT_ID
${YELLOW}
4.Run example queries(from lab page)

5.run last QUERY(from lab page) manually here ${CYAN}https://console.cloud.google.com/bigquery?project=$PROJECT_ID

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
