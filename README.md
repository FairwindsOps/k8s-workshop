# Kubernetes workshop at Google SF 8/31/17 with ReactiveOps




## The web app
The web app is a Ruby app using Sinatra. The app is a key value storage and retrieval service. It has a redis backend. 
* [instance_ip]:80/set/[key]/[value] will set a key value 
* [instance_ip]:80/[key] will retreive the value
* [instance_ip]:80 returns "Hello from Docker"
* [instance_ip]:80/app return "Look Ma, no hands"
