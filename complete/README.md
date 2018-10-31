# Kubernetes workshop with ReactiveOps

## Complete Workshop Walkthrough

1. Create namespace
    * `kubectl apply -f namespace.yml`
1. Deploy redis:
    * `kubectl apply -f 01_redis/`
    * `kubectl get deployments`
    * `kubectl get pods`
    * `kubectl describe pod <redis primary>`
    * `kubectl logs <redis primary>`
    * `kubectl get services`
1. Deploy the basic webapp
    * `kubectl apply -f 02_webapp/`
    * `kubectl get services`
    * `curl [external_ip]`
    * `curl [external_ip]/asdf/1234`
    * `curl [external_ip]/asdf`
1. Scaling
    * Install `ab`: `sudo apt-get install apache2-utils --yes`
    * Apply some load `ab -n 30000 -c 100 http://[external_ip]:[port]/`

