# Kubernetes workshop with ReactiveOps

## Workshop Agenda

* Deploy redis
`kubectl apply -f redis`

* Deploy web application
    * `kubectl apply -f webapp/deploy/app.configmap.yml`
    * `kubectl apply -f webapp/deploy/app.service.yml`
    * `kubectl apply -f webapp/deploy/app.deployment.yml`
    * `kubectl apply -f webapp/deploy/app.service.yml`

* Manually scale webapp
`kubectl scale deployment webapp --replicas=3`
- Delete a pod, it comes right back

* Scale it back down
`kubectl scale deployment webapp --replicas=1`

* Set up Pod autoscaling
`kubectl apply -f webapp/deploy/app.horizontal_pod_autoscaler.yml`

* Generate some load!	
`ab -n 10000000 -c 30 http://$APP_IP/app`

## The web app
The web app is a Ruby app using Sinatra. The app is a key value storage and retrieval service. It has a redis backend. 
* [instance_ip]:80/set/[key]/[value] will set a key value 
* [instance_ip]:80/[key] will retreive the value
* [instance_ip]:80 returns "Hello from Docker"
* [instance_ip]:80/app return "Look Ma, no hands"
