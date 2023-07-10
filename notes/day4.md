 94  kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
   95  cd training/installation/
   96  curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O
   97  kubectl create -f custom-resources.yaml
   
 ---    
 
            192.168.0.50:80
                192.168.0.101:30080             DNS: app1.mycompany.com = 192.168.0.50
                192.168.0.102:30080               |
                192.168.0.103:30080               |                          http://app1.mycompany.com
                                                  |                          http://nginx-services:81 !!! This is not gonna work.
        |- 192.168.0.50 - LoadBalancer            |                  |- 192.168.0.201 - Client A
        |                                         |                  |    
 ------------------------------------------------------------------------ company network (amazon network) 192.168.0.0/16
  |                                                                     
  |= 192.168.0.101 - Kub Server 1                                       
  ||                  v     |- 10.10.0.101 - NginxPod-1 -. Webserver                     
  ||                  v           Nginx : 80                                    
  ||                  v              nginx.conf | wp.conf 
  ||                  v                  db_url: mariadb-service:3307
  ||                 Linux Kernel
  ||                    netFilter: 10.10.1.101:3307 > 10.10.0.103:3306
  ||                    netFilter: 10.10.1.102:81   > 10.10.0.101:80 | 10.10.0.104:80 
  ||                    netfilter: 10.10.2.103:80   > 10.10.0.105:80
  ||                        netFilter is doing the balancing
  ||                        netFilter is not a full load balancer (It has no queues) ** We will talk about this in more detail... in the impact of this issue.
  ||                    netfilter: 192.168.0.101:30080 > 10.10.2.103:80
  ||
  |= 192.168.0.104 - Kub Server 4
  ||                  v     |- 10.10.0.104 - NginxPod-2(again) - Webserver
  ||                  v     |      Nginx : 80
  ||                  v     |         nginx.conf | wp.conf 
  ||                  v     |             db_url: mariadb-service:3307
  ||                  v     |- 10.10.0.105 - IngressController (nginx) - Reverse Proxy
  ||                  v                                 app1.mycompany.com -> nginx-service:81  <<< Ingress 
  ||                  v                                 app2.mycompany.com -> nginx-service1:81 <<< Ingress 
  ||                  v                                 app3.mycompany.com -> nginx-service2:81 <<< Ingress 
  ||                  v                                 app4.mycompany.com -> nginx-service3:81 <<< Ingress 
  ||                  v                                 app5.mycompany.com -> nginx-service4:81 <<< Ingress 
  ||                  v           Nginx : 80
  ||                 Linux Kernel
  ||                    netFilter: 10.10.1.101:3307 > 10.10.0.103:3306
  ||                    netFilter: 10.10.1.102:81   > 10.10.0.101:80 | 10.10.0.104:80 
  ||                    netfilter: 10.10.2.103:80   > 10.10.0.105:80
  ||                    netfilter: 192.168.0.104:30080 > 10.10.2.103:80
  ||
  ||= 192.168.0.103 - Kub Server 3
  ||                   v  |- 10.10.0.103 - MariaDBPod-1
  ||                   v         MariaDB: 3306
  ||                  Linux Kernel
  ||                    netFilter: 10.10.1.101:3307 > 10.10.0.103:3306
  ||                    netFilter: 10.10.1.102:81   > 10.10.0.101:80 | 10.10.0.104:80 
  ||                    netfilter: 10.10.2.103:80   > 10.10.0.105:80
  ||                    netfilter: 192.168.0.103:30080 > 10.10.2.103:80
  ||< (1)  
  ||
  ||= 192.168.0.11 - Kub Server Control Plane
                         |- 10.10.0.10 - KubernetesDNS
                                            mariadb-service = 10.10.1.101
                                            nginx-service   = 10.10.1.102
                                            ingress-controller-service = 10.10.2.103
  
  (1) Kubernetes virtual network 10.10.0.0/16
  
For sure, we don't want to contact my pod thru its IP. Why?
  1- We don't know the IP in advance
  2- We are in a production environment (HA). Pod Ips can change over the time... we cannot rely on IPs
  3- People or programs form the outside world (outside the cluster) won't be a able to use those IPs... 
     as they are in a different network
  4- How many nginx pods am I going to have? Just one? Maybe or maybe not
    Keep in mind that we are in a production environment (SCALABILITY)
    That means, at a certain point of time... we could have 2 nginx servers ... or 200

## What a SERVICE IS IN KUBERNETES?

We have 3 types of services:

### ClusterIP

> A clusterip service is:    A load balancing IP    +    an entry in the internal Kubernetes DNS

We create a service call: mariadb-service
- In the kubernetes DNS, I'm going to dd that entry

Service IPs do not change over the time... they are consistent.
The ServiceIP is actually a Virtual IP... It is just an entry in netFilter. 

ClusterIP services are meant for INTERNAL COMMUNICATIONS, sucha as the one between nginx -> mariadb

### NodePort

It is a ClusterIP service + A Port redirection in every single host, exposing the service IP & PORT 
in the public IP Adress of the host... at a port bigger than [30000, 32???]

### LoadBalancer

The external load balancer is something I need to configure on my own...
For sure, previously, I had to install it.

The good news is that Kubernetes has a Thirs service type: LoadBalancer

Is a NodePort + automatic configuration of an external "COMPATIBLE" loadbalancer

When we rent a kubernetes cluster in any public cloud: AWS, GOOGLE CLOUD PLATFORM, AZURE
They will provide a Compatible LoadBalancer for you (... prepare money for that!!!! It is an extra !)

If I want to install Kubernetes on-premisses, there is just 1 unique Compatible Load balancer with kubernetes: MetalLB

---
### NetFilter? 

This is a component (module) that we have in the Linux Kernel.
Every single network package that is moved inside a Linux OS, goes thru NetFilter
A service IP is just a RULE that we configure in NETFILTER


---

There is no way to autoconfigure the public DNS in a standard kubernetes.

OpenShift, for example, which is RedHat Kubernetes Distribution, brings a new Object that helps us with this: ROUTE


---

How many ClusterIP , NodePort and LoadBalancer Services are we going to have in any standard Kubernetes cluster?
                
                Percentage                  Why?
ClusterIP           All but that one.       Both internal pods... or pods that are going to be exposed
                                            are going to be managed as provate communications ... as the reverse proxy
                                            (which is running inside the cluster), is going to protect them
NodePort            0                       Whenever we want to expose a service... we don't want to be configuring the external load balancer. That makes no sense.!
                                            They are ok for testing... just for that
LoadBalancer        1                       Those are meant for public services
                                            We are only going to have 1 (maybe 2.. in weird scenarios) public service:
                                                Reverse Proxy. This one is going to proected the rest of the services
                                                      ||
                                                Ingress Controller -> Pod (or several pods... in case you need more load of work) Cluster of reverse proxies
                                                

## Ingress

It is just a configuration (a rule) for the Ingress Controller (reverse proxy)

The good thing is that I don't need to learn how to configure Nginx as a reverse proxy... or haproxy... or envoy... or apache... pr... or...
I'm going to define that ingress in YAML.
Kubernetes is going to transforms that into the actual syntax that is required for my current Reverse Proxy (ingress controller)
If tomorrow I decide to change my IUngress Controller (my reverse proxy) ... nothing needs to be changes.
Kubernetes is going to take care of that
