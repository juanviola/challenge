# Challenge
The idea of doing deployments to production environments without any downtime it’s known as “Blue Green Deploys”, This can be done at many different ways.


## Option with Docker Cloud
In this example I'll show how to doit using my own node. You can use different cloud services providers like (AWS/DigitalOcean/Microsoft Azure/Softlayer).

1) login into a server with ubuntu-14.04 
2) Install docker 
```sh
apt-get install apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo 'deb https://apt.dockerproject.org/repo ubuntu-precise main' > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install docker-engine
apt-get install python-pip
pip install docker-cloud
```

3) Install dockercloud-agent (get the link from cloud.docker.com using your own username/password)
Click on the link "Nodes > Bring your own node" a pop up window will appear and copy the link shown below. This links includes your hash key.
   >NOTE: Before you begin, make sure that ports 6783/tcp and 6783/udp are open on the target host. Optionally, open port 2375/tcp too
```sh
curl -Ls https://get.cloud.docker.com/ | sudo -H sh -s <your-docker-cloud-hash>
```

4) once the agent is started create a new stack from de dockercloud UI using the stack file Ch-v1.yml and click on "Create and Deploy"
5) when the containers are up the balancer will be pointing to our green container "webx-green" with the release 0.0.1 and will be serving at port 80
6) to switch to new release 0.0.2 we will be running the following commands
   > Note: You must run "docker login" to start a session to docker cloud first
```sh
docker-cloud service set --link webx-blue:webx-blue lbx
docker-cloud service redeploy lbx
```
  
7) Now the balancer will be pointing to our blue container "webx-blue" release 0.0.2

>Another possibility is having an NGINX/Haproxy running inside of a container (or in a box) and getting information from docker trough the API, and managing the balancer configuration to put IN/OUT of service those container's

>Or using Service Registry tools like zookeeper in convination with Consul and NGINX. 

## Health Check's 

### local bash health check
This is a simple bash health check running curl against to the localhost, if the response header is not equal to 20x|30x then, we will kill the main docker process, so the docker container will be regenerated or taken out of the balancer.

```sh
#!/bin/bash
while true; do
sleep 10
curl -sI --connect-timeout 3 -m 3 http://localhost:3000/ping | head -n1 | egrep -i "(20[0-9]|30[0-9])" > /dev/null
if [ "$?" != "0" ]; then
 pidof node | xargs kill 
fi
done
```

to get the "tactivos/devops-challenge:0.0.1" release supporting the local health check script run the following commands 

```sh
git clone https://github.com/juanviola/challenge.git
cd challenge
docker build -t tactivos/devops-challenge:0.0.1 .
```

### Additional health check option's 

##### Running balancer health checks
Also, Health check can be made with the balancer "Haproxy" setting the environment variable on containerized haproxy server
>HTTP_CHECK=OPTIONS /ping 


##### or adding this line configuration to haproxy.cfg backend's configuration
On dedicated Box with haproxy 
>option httpchk OPTIONS /ping 

##### Running monit
Health checks also can be made with monit command

## Bonus 1
#### Limit memory and cpu by adding the following configuration to the stack file

```
cpu_shares: 512
cpuset: 0,1
mem_limit: 100000m
memswap_limit: 200000m
```

## Bonus 2
#### Scale Horizontal with AWS
We can use the AWS ELB service in convination with Amazon CloudWatch and a "Scale based on demand" plan. Amazon CloudWatch monitors the metrics to see if new nodes need to be created, based on the setting we provided before. 
When a threshold is reached, CloudWatch fires a trigger to the scale IN/OUT policy.

## Bonus 3
Service discovery made with ELB as (Service Registry)

>This is a good read about service discovery in a Microservices environment 
https://www.nginx.com/blog/service-discovery-in-a-microservices-architecture/


