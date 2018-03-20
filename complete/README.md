# Kubernetes workshop with ReactiveOps

## Complete Workshop Walkthrough

1. Create namespace
    * `kubeclt apply -f namespace.yml
1. Deploy redis:
    * `kubectl apply -f 01_redis/`
    * `kubectl get deployments`
    * `kubectl get pods`
    * `kubectl describe pod <redis master>`
    * `kubectl logs <redis master>`
    * `kubectl get services`
1. Deploy the basic webapp
    * `kubectl apply -f 02_webapp/`
    * `kubectl get services`
    * `curl [external_ip]`
    * `curl [external_ip]app`
    * `curl [external_ip]/set/asdf/1234`
    * `curl [external_ip]/asdf`
1. Scaling
    * Apply some load `ab -n 30000 -c 100 http://[external_ip]/app`


## The web app
The web app is a Ruby app using Sinatra. The app is a key value storage and retrieval service. It has a redis backend.
* [instance_ip]:80/set/[key]/[value] will set a key value
* [instance_ip]:80/[key] will retreive the value
* [instance_ip]:80 returns "Hello from Docker"
* [instance_ip]:80/app return "Look Ma, no hands"
