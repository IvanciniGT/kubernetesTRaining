How many pods do we want to create inside a kubernetes cluster? 0 No one

Why? we don't want to create containers ourselfs
Kubernetes is the one who is going to create containers inside the cluster

In order to do this... I cannot create a POD... but to provide to kubernetes a POD TEMPLATE

# Object that allow to define a pod template:

- Deployment

A pod template + a number of replicas 

- Statefulset
- Daemonset

# Object that allow to parameterize containers

- Configmap
- Secret            Secrets store values encrypted within the Kubernetes DATABASE.
                    Not in the source file (where they are defined in base64)

# Volumes:

## Volume usages:
    
    TYPES: nfs, cabinet, iscsi, cloud

PERSISTENT VOLUMES: Is a volume outside the cluster
    - Keep the information safe in case of a container deletion
    - Share folders/files between containers :
        - Containers in different pods
----------------------------------------------------------------------------------------------
NON PERSISTENT VOLUMES: Are volumes stored locally (in a host)
        - Containers in the same pod
    - inject files/folder (config files) into a container
    - increase the performance of certain disk operations (we can use RAM memory as a folder)
    
    TYPE: hostVolume, emptyDir, confiMap, secret
    
    
Why a hostVolume is considered a NON PERSISTENT VOLUME in KUBERETES?


hostVolumen is just a path in the host fs that will be mounted inside a container fs


Node A - Host
    /data/mariadb
    container mariadb x
        /data/mariadb -> /var/lib/mysql
---


We would have a cluster: HUGE CLUSTER : 200 servers 64 cores each and 256 Gbs of RAM
We are going to have a team for the cluster administration.

Me, I'm gonna be a cluster user, that wants to deploy a WebSite in the cluster thru WP.

Who is going to create the deployment file?
- Someone from the app team

As a guy who is going to deploy an app to a cluster...
I want to deploy my app.

The cluster administrators are interested in :
- how many resources do I need... beacuse they are going to charge me depending on that.
    - 4 cpus            
    - 16 Gbs
    - storage:
        - How much space do you need? I need at least 10Gbs
        - How should be that storage? Redundant... how much redundant? Each piece of data is stored at least in 3 different places
                                      Fast... or not that fast
                                      Encrypted
        - Do you need backups?


---- 
storage: 10Gi

Is that 10 Gigabytes? 10Gb

I write 10 Gibibytes

1 Gigabyte = 1000 Megabytes
1 Megabyte = 1000 Kilobytes
1 Kilobyte = 1000 bytes

1 Gibibyte = 1024 Mebibytes
1 Mebibyte = 1024 Kibibytes
1 Kibibyte = 1024 bytes


THAT IS NOT TRUE AT ALL !!! BE CAREFUL !!!!
THEY CHANGED THAT ! That's not new