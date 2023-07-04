
# Kubernetes

Is a software tool for managing a production environment.

## Production environment

- High Availability
    We will try to make sure that the environment (the apps running in that environment) are ONLINE most of the time they supposed to be online.
    - Software have bugs
    - Hardware is not perfect and have problems.
    We will use "Redundancy"
        We will have not only one hardware .. but a bunch of them (redundant hardware)

    We will try to avoid data lost
        We will use that "Replication" concept here again. Each data is going to be store in at least 3 different locations
        We will make use of backups, to make sure that even in case of a disaster, I will able to recover the info.

- Scalability

    Tries to make sure that we have good enough response times in any scenario.
    That could imply that I need to increase(adjust) my infraestructure.

    I have a dev environment with a server 16Gbs RAM and 8 cores running MariaDB. A query requires 200ms to be executed in that environment
    Let's say that they have prepared for me a prod env with 3 servers (64Gbs, 12 Cores) running a cluster of MariaDB. Should the performance (response time)
    be better in this case? Not always 

    MariaDB Cluster                     Sec1   Sec2
        Server 1 - Instance of MariaDB  DataA  DataB
        Server 2 - Instance of MariaDB  DataA  DataC
        Server 3 - Instance of MariaDB  DataB  DataC

    If I have just 1 server... I am able to store 1 data unit per unit of time
    It I haver a cluster of 3 servers... I'm just able to store 1.5

    App1
        Day 1     100 users
        Day 100   102 users     In this case we don't need scalability
        Day 400    98 users 

        Hospital management app. where doctors are going to store information about patients. 

    App2 
        Day 1   100 users
        Day 2   20000 users     An online game      In this case we can make use of VERTICAL SCALABILITY: MORE MACHINE 
        Day 3   3000000 users

    App3  INTERNET
        Hours n   100 users         McDonalds       3am? 8am, 10am? 10 requests             13:00 A bunch of them       At 16:30 just a few again... At 20:00 (Milan and Rome)
        Hours n+1 1000000 users 
        Hours n+2 2000 users            HORIZONTAL SCALABILITY: MORE MACHINES !
        Hours n+3 3000000 users   

- Security


    Cluster of WebServers                         Load Balancer          Reverse Proxy                                 proxy                             Clients
        Webserver1 - app 1                  <     192.168.100.200        192.168.100.240                               192.168.100.100                   192.168.100.200
            IP: 192.168.100.101
        Webserver2 - qpp 1                  <
            IP: 192.168.100.102
        Webserver3 - app 1                  <
            IP: 192.168.100.103
        Webserver4 - app 1                  <
            IP: 192.168.100.104

Proxy: It is a software tool that acts in behalf of a client... to protect client identity

Reverse proxy: It is software too to protect our backend servers identity

In a bunch of production environment usually the reverse proxy and the load balancer functions are done by the same software tool: 
- nginx
- apache httpd
- haproxy
- envoy

In kubernetes that's not the case!

---

A grocery store                                                             <<< Production environment too...It is not that reliable
- Meat 
- Veggies
- Eggs
- Milk
- We have 1 person attending clients ... Mostly where we pay for the goods
- 1 Entry (gate)


Supermarket... is bigger                                                    <<< Kubernetes cluster / production environment
You will find like different 
- Butcher shop  (Meats)                                                         SERVICE
  - Cold room                                                                   VOLUME (different kind of volumes)
  - Refrigerated Counters                                                       VOLUME (HDD)
  - Several Butchers (2)                                                        RUNNING PROCESS
  - Each butcher is going to be working in its own place (5 places)             CONTAINER  (CPU, RAM): Isolated environment
    - cutting board                                                             Memory RAM
    - knives                                                                    CPU
    - weighing machine
  - Number ticket machine / Banner                                              Load Balancer
  - Meat                                                                        Data
- ... (fish)                                                                    SERVICE
- ... (veggies)                                                                 SERVICE
- Paying                                                                        SERVICE
  - cashier lines (5)                                                           CONTAINER
      - a person (cashier)
      - machines
      - money                                                                   Data
  - Unique queue                                                                Load Balancer
- Gate for customers (just 1... maybe several)                                  Reverse Proxy (Ingress Controller)
- Gate for Goods?                                                               Reverse Proxy (Ingress Controller)
- Banners to help client find / sections                                        DNS Entries
- SuperMarket manager                                                           Kubernetes
Fridge
Butcher... cashier??? Profiles                                                  Container image

Service: Load balancing + DNS Entry

Usually we will have a cluster of kubernetes, already deployed and ready to work with.
In that cluster I will deploy my own SERVICE
Those services are going to be provided by PODS
A POD is a set of CONTAINERs

---

Kubernetes cluster

Machines 1 (Node 2)              Machine 2                  Machine 3                                 Machine 10

POD 1_a                            Pod 1_b                  Pod 2                                       Pod 3
Pod 6                              Pod 7_b
Pod 7_a
    Container A (1cpu 1gbRAM)
        Running Process
    Container B (1cpu 2gbRAM)
        Running Process
---

# Container

A container is just an Isolated environment inside an OS (running a Linux Kernel) where we can execute process.

Why would I want to create an isolated env to execute a process? 
- Isolation:
  - Security
- Limit resources

Webserver - BUG -> 100% CPU  OFFLINE
DB: MySQL               OFFLINE

There is a different technology that allows us to create isolated environments, which is called? Virtual machines

Containers are a "cheaper" alternative to Virtual Machines when trying to create isolated environments.

Actually Virtual machines have a bunch of problems compared to containers.

Problems that we have when working with virtual machines? 
- Huge waste of resources
- Setup complexity
- They are not regulated by any standard

      Process A  | PS B
    ---------------------
      Operating System
    ---------------------
            HOST



      Process A  | PS B
    ---------------------
      OS 1       | OS 2
    ---------------------
      VM 1       | VM 2
    ---------------------
      Hypervisor (Citrix, vmware, virtualbox, hyperv...)
    ---------------------
      Operating System
    ---------------------
            HOST            



      Process A  | PS B
    ---------------------
      C 1        | C 2
    ---------------------
      Containers manager (Docker, Podman, **ContainerD, CRIO**)
    ---------------------
      Operating System
    ---------------------
            HOST 