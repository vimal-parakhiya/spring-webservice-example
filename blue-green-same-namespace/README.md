 # OpenShift Blue/Green Service Deployment - Single Namespace
 
 - Create new project
 
    `oc new-project oc-greeting-blue-green --description="Openshift Greeting Project - Blue/Green" --display-name="Openshift Greeting - Blue/Green"`
 
 - Build and Tag application - Blue version
    
    Set `service.type=Blue` in `application.properties` in `greeting-service` project and then run following command.
 
    `mvn clean install -f greeting-service/ && cp greeting-service/target/greeting-service-1.0.0.war docker/os-greeting-service/ && docker build -t os-greeting-service-blue docker/os-greeting-service/`
 
- Build and Tag application - Green version
    
    Set `service.type=Green` in `application.properties` in `greeting-service` project and then run following command.

    `mvn clean install -f greeting-service/ && cp greeting-service/target/greeting-service-1.0.0.war docker/os-greeting-service/ && docker build -t os-greeting-service-green docker/os-greeting-service/`
 
- Tag & Push Images in OpenShift Project ImageStreams
    ```
     docker tag os-greeting-service-green $(minishift openshift registry)/oc-greeting-blue-green/os-greeting-service-green
     docker tag os-greeting-service-blue $(minishift openshift registry)/oc-greeting-blue-green/os-greeting-service-blue
     docker push $(minishift openshift registry)/oc-greeting-blue-green/os-greeting-service-green
     docker push $(minishift openshift registry)/oc-greeting-blue-green/os-greeting-service-blue
     ```
 - Deploy Service - Blue & Green
    ```
    oc apply -f blue-green-same-namespace/openshift-blue.json
    oc apply -f blue-green-same-namespace/openshift-green.json
    ```
 - Expose Service - Blue 
 
    `oc expose service/greeting-service-blue --name=greeting-service-route --hostname=greeting.192.168.64.2.nip.io`
 
 - Patch Route to switch from Blue to Green 
 
    `oc patch route/greeting-service -n oc-greeting-blue-green --patch '{"spec":{"to": {"name":"greeting-service-green"}}}'`
 
## Run following command to switch from Blue to Green and vice-versa at every 10 seconds
 ```
  while true; 
  do 
  oc patch route/greeting-service-route -n oc-greeting-blue-green --patch '{"spec":{"to": {"name":"greeting-service-green"}}}' 
  sleep 10 
  oc patch route/greeting-service-route -n oc-greeting-blue-green --patch '{"spec":{"to": {"name":"greeting-service-blue"}}}' 
  sleep 10 
  echo "-----------------------------------------------------" 
  done;
  ```

Note: Test run indicates that there will be zero downtime as shown below. During this run, route is toggled 7 times by switching target service from Green to Blue and Blue to Green.

`Down Time Statistics: DownTimeTracker{downTimes=[] Average Down Time (ms): 0}`