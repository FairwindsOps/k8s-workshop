# Kubernetes workshop with ReactiveOps

This repository stores the various docs and code ReactiveOps uses to do onsite trainings. To accomodate different audinces, there are a few different tracks:

* [Assembly Required Workshop Walkthrough](assembly_required/README.md)
  * Follow along the README.md to create, edit and upload your own yaml kubernetes manifests
* [Complete](complete)
  * The same manifests from the Assembly Required Workshop with the values filled in for you. 

## Workshop Interaction

In the workshops above you will be launching a two tier webapp. The web app is a Ruby app using Sinatra. The app is a key value storage and retrieval service with a Redis backend.

### Interacting with the App
* [instance_ip]:[port]/[key]/[value] will set a key value
* [instance_ip]:[port]/[key] will retreive the value
* [instance_ip]:[port] returns "Hello from Kubernetes"

### Optional Configuration
* When environment variable `CHAOS` is set to `true` then the webapp will die after a randomly generated number of requests between 1 and 100.
