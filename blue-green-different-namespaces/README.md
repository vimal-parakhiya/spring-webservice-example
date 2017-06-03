# Openshift Examples

## Openshift Blue Green Examples (Different Namespaces)

### Prerequisites
- Install [Docker](https://docs.docker.com/engine/installation/)
- Install [Minishift](https://github.com/minishift/minishift) 

### Deploy web-application in Minishift - Blue Side
- Start Minishift 

    `minishift start`
- Login into OC 
    
    `oc login -u system:admin`
- Create new project (Blue) 

    `oc new-project oc-greeting-blue --description="Openshift Greeting Project - Blue" --display-name="Openshift Greeting - Blue"`

- Setup Minishift docker-env

    `minishift docker-env`
    
    `eval $(minishift docker-env)`

- Login into Docker Registry

    `docker login -u developer -p $(oc whoami -t) $(minishift openshift registry)`
    
- Create Docker Image

    `docker build -t os-java-maven-base docker/os-java-maven-base/`
    
    `mvn clean install -f greeting-service/ && cp greeting-service/target/greeting-service-1.0.0.war docker/os-greeting-service/ && docker build -t os-greeting-service docker/os-greeting-service/`
    
- Tag Docker Image

    ` docker tag os-greeting-service $(minishift openshift registry)/oc-greeting-blue/greeting-service`
    
- Push Docker Image    
    `docker push $(minishift openshift registry)/oc-greeting-blue/greeting-service`
 
- Apply Deployment & Service Configurations 
    
    `oc apply -f blue-green-different-namespaces/openshift-blue.json`

- Define Route to expose the `greeting-service`

    `oc expose service/greeting-service --hostname=greeting.192.168.64.2.nip.io`

- Access & Verify the Service
    `curl http://greeting.192.168.64.2.nip.io/greeting`
   
   
### Deploy web-application in Minishift - Green Side
- Create new project (Green)

    `oc new-project oc-greeting-green --description="Openshift Greeting Project - Green" --display-name="Openshift Greeting - Green"`

- Create Docker Image

    `docker build -t os-java-maven-base docker/os-java-maven-base/`
    
    `mvn clean install -f greeting-service/ && cp greeting-service/target/greeting-service-1.0.0.war docker/os-greeting-service/ && docker build -t os-greeting-service docker/os-greeting-service/`
    
- Tag Docker Image

    `docker tag os-greeting-service $(minishift openshift registry)/oc-greeting-green/greeting-service`
    
- Push Docker Image    
    `docker push $(minishift openshift registry)/oc-greeting-green/greeting-service`
 
- Apply Deployment & Service Configurations 
    
    `oc apply -f blue-green-different-namespaces/openshift-green.json`

- Define Route to expose the `greeting-service`

    `oc expose service/greeting-service --hostname=greeting.192.168.64.2.nip.io`

- Access & Verify the Service
    `curl http://greeting.192.168.64.2.nip.io/greeting`

## Execute following to switch routes alternatively at every 10 seconds

`while true; do oc delete route/greeting-service -n oc-greeting-blue && oc expose service/greeting-service --hostname=greeting.192.168.64.2.nip.io -n oc-greeting-green; sleep 10; oc delete route/greeting-service -n oc-greeting-green && oc expose service/greeting-service --hostname=greeting.192.168.64.2.nip.io -n oc-greeting-blue; sleep 10; echo "---------------------"; done;`

### Down Time Statistics
Down Time Statistics: {Average Down Time (ms): 215, downTimes=[174, 184, 217, 194, 167, 183, 255, 207, 219, 261, 245, 207, 256, 254, 195, 228, 199, 226, 224, 211, 223, 226, 203, 244, 215, 229, 228, 250, 75, 265]}
