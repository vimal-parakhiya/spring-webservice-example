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

    health_check_command="curl $HEALTH_ENDPOINT"

    interval=1
    ((end_time=${SECONDS}+20))

    until (((${SECONDS} > ${end_time})) || $health_check_command | grep -q $PATTERN)
    do
       echo "Service is not up yet"
       sleep ${interval}
    done

    PATTERN="\"id\":2"
    if $health_check_command | grep -q $PATTERN; then
        app_status=0;
    fi
    kill $APP_PID
}
run_and_do_check_health \
    "pom.xml" \
    "target/spring-webservice-example-1.0-SNAPSHOT.war" \
    "localhost:8100/greeting" \
    && exit $app_status



