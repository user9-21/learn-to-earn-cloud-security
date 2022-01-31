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




bq query --use_legacy_sql=false \
'SELECT
   bikeid,
   starttime,
   start_station_name,
   end_station_name,
FROM
  `bigquery-public-data.new_york_citibike.citibike_trips`
LIMIT 5'

bq query --use_legacy_sql=false \
'SELECT
  EXTRACT (DATE FROM TIMESTAMP(starttime)) AS start_date,
  start_station_id,
  COUNT(*) as total_trips
FROM
 `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE
   starttime BETWEEN DATE("2016-01-01") AND DATE("2017-01-01")
GROUP BY
    start_station_id, start_date
LIMIT 5'


echo "${GREEN}${BOLD}

Task 1 Completed

${RESET}"

bq mk --default_table_expiration 86400 bqmlforecast

bq query -destination_table bqmlforecast.training_data  --use_legacy_sql=false \
'SELECT
 DATE(starttime) AS trip_date,
 start_station_id,
 COUNT(*) AS num_trips
FROM
 `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE
 starttime BETWEEN DATE("2014-01-01") AND ("2016-01-01")
 AND start_station_id IN (521,435,497,293,519)
GROUP BY
 start_station_id,
 trip_date'


echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"


bq query --use_legacy_sql=false \
'CREATE OR REPLACE MODEL bqmlforecast.bike_model
  OPTIONS(
    MODEL_TYPE="ARIMA",
    TIME_SERIES_TIMESTAMP_COL="trip_date",
    TIME_SERIES_DATA_COL="num_trips",
    TIME_SERIES_ID_COL="start_station_id",
    HOLIDAY_REGION="US"
  ) AS
  SELECT
    trip_date,
    start_station_id,
    num_trips
  FROM
    bqmlforecast.training_data'


echo "${GREEN}${BOLD}

Task 3 Completed

${RESET}"

bq query --use_legacy_sql=false \
'SELECT
  *
FROM
  ML.EVALUATE(MODEL bqmlforecast.bike_model)'

echo "${GREEN}${BOLD}

Task 4 Completed

${RESET}"

bq query --use_legacy_sql=false \
' DECLARE HORIZON STRING DEFAULT "30"; #number of values to forecast
 DECLARE CONFIDENCE_LEVEL STRING DEFAULT "0.90";
 EXECUTE IMMEDIATE format("""
     SELECT
         *
     FROM
       ML.FORECAST(MODEL bqmlforecast.bike_model,
                   STRUCT(%s AS horizon,
                          %s AS confidence_level)
                  )
     """, HORIZON, CONFIDENCE_LEVEL)'




echo "${GREEN}${BOLD}

Task 5 Completed

${RESET}"

echo "${GREEN}${BOLD}

Game Completed.

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
