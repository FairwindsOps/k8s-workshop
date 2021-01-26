# Kubernetes workshop with Fairwinds

## Complete Workshop Walkthrough
Below are the steps that we'll be using to deploy a complete web app. Note that this demo will deploy a broken application and we'll be fixing the Kubernetes yaml documents to make the deployment successful.

### Deploying Redis Database
First we'll be:
- Deploying a new Namespace for our application
- Deploying a redis server into the new namespace
- Reviewing the objects that we've deployed with Kubernetes (Deployments, Pods)
- Getting Logs from the deployed resources via `kubectl`

1. Create namespace in Kubernetes
    * `kubectl apply -f namespace.yml`
      Uses `kubectl` to `apply` the file (`-f`) with the `Namespace` definition. Note that the namespace we're deploying into is defined in the yaml documents in `01_redis/`.
1. Deploy Redis Master and Replica
    * `kubectl apply -f 01_redis/`
      Uses `kubectl` to `apply` all `yaml` definitions in the folder `01_redis/`.
    * `kubectl get deployments`
      Gets the `deployment` resources from Kubernetes in the `default` namespace. You will not see the redis deployments since we have deployed them to a different namespace.
    * `kubectl get pods`
      Gets the pods in the `default` namespace. You won't see the redis pods since they've been created in another namespace.
    * `kubectl get --namespace k8s-workshop deployments,pods`
      Gets the `deployments` _and_ `pods` with `kubectl` in the `k8s-workshop` namespace. You should now see that adding `--namespace k8s-workshop` will scope your `get` request to the `k8s-workshop` namespace.
    * `kubectl describe --namespace k8s-workshop pod <pod name>`
      Describes the current state of the `<pod name>` pod in Kubernetes. You can copy paste the name of the pod where you see `<pod name>`.
    * `kubectl get --namespace k8s-workshop services`
      This lists all the `service` definitions in the `k8s-workshop` namespace.
    * `kubectl logs --namespace k8s-workshop <pod name>`
      This prints the pods (containers) `logs` to your terminal. You can paste any pod name in the `k8s-workshop` namespace to replace `<pod name>`.

We should now see a healthy Redis Master and Replica in the `k8s-workshop` namespace in Kubernetes.

### Deploying the Web App
Next we'll be:
- Deploying the web app into the `default` namespace (A different namespace from the one we created above)
- Watching the Cloud Load Balancer create external access to the web app
- CURLing the newly deployed web app to test manually
- Looking at the logs of the web app
- Fixing the broken web app deployment be deploying to the correct namespace
- CURL the web app again to test

1. Deploy the basic webapp
    * `kubectl apply -f 02_webapp/`
      This deploys all the yaml definitions in the `02_webapp/` folder. Note that we are _not_ defining the namespace in the `metadata` of the yaml, so it will default to the `default` namespace configured with `kubectl`.
    * `kubectl get services`
      Gets all the `service` definitions in the `default` namespace. We are going to wait until `External IP` has an IP Address.
1. Test the web app
    * `curl [external_ip]`
      This should show a hello world type response.
    * `curl [external_ip]/asdf/1234`
      When you `curl` this website, you should experience an error connecting to Redis.
    * `kubectl logs <webapp pod name>`
      Let's look at the errors in the logs from the pod... Cannot connect to redis because it's default namespace DNS resolution won't work from a different namespace.
1. Fix the broken deployment
    * `kubectl delete -f 02_webapp/`
      This will delete all the objects we created so that we can deploy correctly into the `k8s-workshop` namespace.
    * `kubectl apply -f 02_webapp/ --namespace k8s-workshop`
      This overrides the unset `default` namespace and deploys all the yaml files into the `k8s-workshop` namespace.
    * `kubectl get services --namespace k8s-workshop`
      We need to see the _new_ service we've created, so the Load Balancer IP will have changed.
1. Test the new deployment
    * `curl [external_ip]/asdf/1234`
      Now we see that the web app correctly saves the key and value to the database.
    * `curl [external_ip]/asdf`
      We can also query the value from the database.

### Scaling the Application based on CPU
This section allows us to load test the web app and see the cluster responding by scaling the pod count up.

* Apply some load `./load.sh`
* Open a new terminal or tab in your shell
* Look at the hpa occasionally to see the cpu usage go up `kubectl get hpa -n k8s-workshop`
* The number of pods should scale up to meet the new demand `kubectl get deployment, po -n k8s-workshop`

### Optional Ingress (Separate Controller Required)
The `03_ingress` sub-directory contains an optional Ingress definition. The `kubernetes.io/ingress.class` annotation may need to be changed to match that of your Ingress Controller.

Note that an Ingress Controller must be installed for Ingress resources to function. See the [Ingress Nginx installation instructions](https://kubernetes.github.io/ingress-nginx/deploy/) for more information.
