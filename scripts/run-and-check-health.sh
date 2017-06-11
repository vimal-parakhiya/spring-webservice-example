#!/usr/bin/env bash
set -e
app_status=1
function run_and_do_check_health() {
    POM_FILE_PATH=$1
    WAR_FILE_PATH=$2
    HEALTH_ENDPOINT=$3
    PATTERN="\"id\":1"

    mvn clean install -f $POM_FILE_PATH
    java -jar $WAR_FILE_PATH &
    APP_PID=$!
    echo "Process running with PID: $APP_PID"

    interval=1
    ((end_time=${SECONDS}+20))

    while ((${SECONDS} < ${end_time}))
    do
        if curl $HEALTH_ENDPOINT | grep -q $PATTERN; then
            echo "Service is up now"
            app_status=0
            break
        else
            echo "Service is not up yet"
            sleep ${interval}
        fi
    done
    kill $APP_PID
}
run_and_do_check_health \
    "pom.xml" \
    "target/spring-webservice-example-1.0-SNAPSHOT.war" \
    "localhost:8100/greeting" \
    && exit $app_status



