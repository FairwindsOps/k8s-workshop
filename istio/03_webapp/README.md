# Converting the Webapp to an Istio service

Notable notables:
* The deployment liveness probe had to be updated to run on the pod. The MTLS configuration causes http healthchecks to fail without extra application changes
* An istio ingress was added
* Since the istio ingress service routes all apps though a single ip address, we added the `webapp` path
* The istio ingress class does not do rewrites in the same way the nginx ingress will so we also needed to add a RouteRule to do the rewrite so the `webapp` path isn't passed on to the webapp
