# Kubernetes workshop with ReactiveOps

## Workshop Walkthrough

1. Create namespace
1. Deploy redis:
    * `kubectl apply -f 01_redis/`
    * `kubectl get deployments`
    * `kubectl get pods`
    * `kubectl describe pod <redis master>`
    * `kubectl logs <redis master>`
    * `kubectl get services`
1. Deploy the basic webapp
    * Edit 02_webapp/app.deployment.yml and set a value for `SECRET1` and `DEPENDENCY_URL`.
    * Edit 02_webapp/app.service.yml and select a port mapping.
    * `kubectl apply -f 02_webapp/`
    * `kubectl get services`
    * `curl [external_ip]:[port]/`
    * `curl [external_ip]:[port]/app`
    * `curl [external_ip]:[port]/set/asdf/1234`
    * `curl [external_ip]:[port]/asdf`
1. Improve the configuration
    * Edit 03_configsandsecrets/app.configmap.yml and set `app.dependency.url` to your `DEPENDENCY_URL` from above.
    * Edit 03_configsandsecrets/app.secret.yml and set `val1` to your base64-encoded `SECRET1`   from above
    * Edit 03_configsandsecrets/app.deployment.yml and set `key` names to match
    * `kubectl apply -f 03_configsandsecrets/`
1. Health and readiness
    * Edit 04_probes/app.deployment.yml and set reasonable values for livenessProbe and readinessProbe
    * `kubectl apply -f 04_probes/`
1. Scaling
    * Apply some load `ab -n 30000 -c 100 http://[external_ip]:[port]/app`
    * Edit 05_scaling/app.deployment.yml and set the CPU to to `200m` and the memory to `300Mi`
    * Edit 05_scaling/*.horizontal_pod_autoscaler.yml and set `targetCPUUtilizationPercentage` and `maxReplicas`
    * `kubectl apply -f 05_scaling/`
    * Apply some load `ab -n 30000 -c 100 http://[external_ip]:[port]/app`
1. Network policy
    * `kubectl apply -f 06_networkpolicy/default.networkpolicy.yml`
    * `curl [external_ip]:[port]/`
    * Delete webapp pods
    * Edit 06_networkpolicy/app.networkpolicy.yml and set the CIDR and label fields
    * `kubectl apply -f 06_networkpolicy/app.networkpolicy.yml`
    * `curl [external_ip]:[port]/`
    * `curl [external_ip]:[port]/asdf`
    * Edit 06_networkpolicy/redis.networkpolicy.yml and set the label fields
    * `kubectl apply -f 06_networkpolicy/redis.networkpolicy.yml`
    * `curl [external_ip]:[port]/asdf`

## The web app
The web app is a Ruby app using Sinatra. The app is a key value storage and retrieval service. It has a redis backend.
* [instance_ip]:80/set/[key]/[value] will set a key value
* [instance_ip]:80/[key] will retreive the value
* [instance_ip]:80 returns "Hello from Docker"
* [instance_ip]:80/app return "Look Ma, no hands"
