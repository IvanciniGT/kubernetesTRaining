# Resources

In every container we will configure the amount of resources that we want to use/be able to use:

resources:
    requests:       This is what kubernetes is going to guarantee to me
        cpu:        2                                    # cores: 1, 2 or 8
                                                         # milicores : 1000m = 1 core
                                                         # 250m.... that means 25% of a core... Actually the equivalent to that.
                                                         # Maybe kubernetes is bringing to me 2 cores at 12.5%
        memory:     1Gi # ask for what you really need
    limits:         I what I could make use of ... in case extra resources are free in the cluster
        cpu:        20 # As much as posible
        memory:     1Gi # ask for what you really need.   Gi.  Mi.  Kb

---
In Kubernetes we have another object type which is called 

# HorizontalPodAutoscaler

By creating an hpa, kubernetes is going to automatically scale the pods of a deployment/statefulset:
- min amount of pods
- max amount of pods
- we will define when does kubebernetes needs to scale up or down... This is going to be specified as a percentage:
    - I the mean cpu usage of the current pods that you have in the pool is bigger than 50% scale up
    - That percentage is calculated from the requested (cpu and memory)


---

The Kubernetes scheduler is a program part of the kubernetes control plane responsible of:
Determining where each pod should be located (in which node)

In order to determine the best option for deploying a pod... the scheduler is goint to take into consideration several aspects... such as:
- resources
- affinities


Kubernetes cluster:
    
                                                        This is the information the scheduler is going to take into consideration
                                                            vvvv
            ACTUAL RESOURCES    REQUESTED RESOURCES     HOW MUCH IS AVAILABLE   ACTUAL USAGE        HOW MUCH RESOURCES ARE FREE
            RAM     CORES       RAM     CORES           RAM     CORES           RAM     CORES           RAM     CPU
Node 1:     16      4           8       3               8       1               4       1               12      3
    Pod1                        8       3                                       4       1

Node 2:     16      4           8       2               0       0              16       4               0       0
    Pod2                        8       2                                       8       2 -> 2 slow down the process
    Pod2b                       8       2                                       8       2
                                                                                ^^^^^^
                                                                                limit
    
I want to deploy a pod1. That pod requires (requests): 8 Gbs of RAM and 3 Cores
Imagine I want to deploy a sencond POD2. That pod requires (requests): 8 Gbs of RAM and 2 Cores
Imagine pod2, wants to use more RAM... It started with 2 -> 8
Imagine pod2, wants to use more CPU... It started with 1 -> 2 cores
Imagine now that pod2 wants to increase its cpu usage ... up to 3 cores...   WELL HERE IT COMES THE LIMIT
    If the pod did ask for 12 Gbs of RAM an 4 cores (as limits) it will be able to increase its cpu usage up to 3
Imagine now that pod2 wants to increase its memory usage ... up to 12Gbs...  WELL HERE IT COMES THE LIMIT

Imagine that now I want to deply a second pod2
Now pod2b.,.. start operating.... 1 core and 4 gbs
The question now... is what if the pod2b wants to increase its cpu usage... up to 2 cores?
The question now... is what if the pod2b wants to increase its memory usage... up to 8 Gb?
    Kubernetes is going to restart pod2

Memory requests and limits are only a extreme security measure that I will define in the cluster..

Where is the actual place where I should limit the container memory?
    DB < - I need to limit the memory in the database configuration
    JAVA APP SERVER: tomcat, webslogic, websphere, jboss... < - Here is where I will limit the memory
    
---

In kubernetes we have 2 additional object types that are created by the cluster administrators:
- LimitRanges
    A cluster administrator is going to limit the amount of memory and cpu that I can both request (or limit)  for each container or pod
    This configuration is per namespace.

    > In this namespace (your ns) you can only ask for container smaller than requests: 2 cores and 2 Gi
                                                                              limits:   3 cores and 4 Gi
                                                                              
    And if you try to ask for a bigger one... that would be forever in PENDING STATUS... The scheduler in not going to schedule it.
    
    Imagine I have a node with 32 Gbs
        And somebody ask for 8 gbs.
    
- ResourceQuota
    Is kind the same concept... but limits the total amount of requested (or limited) resources within a ns.

    > In this namespace you can not request more tha 8 cores... Maybe you can have 8 pods with 1 core... or 1 pod with 8 cores...
    > In this namespace you have a total limit of 12 cores.
    
    

Big Servers for DBs
And raspberry pis for websites (apache-wordpress)

---

In the real life... we don't care that much (some exceptions here) what
is the best cpu and memory requests ans limits that I should specify. <<<<< Monitor
We just care about 1 thing.... The ratio (relation /proportion) between ram and cpu <<<<< Monitor

Nginx   request:         8 Gi and 4 cores
    4 cores... are going to be able to answer a 1000 requests/min... But in that scenario... memory used is only 4 Gi
    
    I will always have 4 gi of free memory (waste of resources)
    The big problem is that I will scale that pod....
    So If I have 10 pods... 40Gis of wasted RAM
    
    
    
---

# Affinities

The Kubernetes scheduler determines the location of each pod in the cluster...

Affinities allows us to give hints to the scheduler for an improved deployment.
We can tell the scheduler where to deploy my pods... Not actually where exactly

Node 1
Node 2 - GPU
    PodA
Node 3

    nodeName: Node2

Usually we do things in a different way. Out clusters will have different kind of nodes 2/3/4 kind of nodes.

Cluster:
    NodesA
        NodeA1  label: kind: NodeA
        NodeA2  label: kind: NodeA
        NodeA3  label: kind: NodeA
    NodesB
        NodeB1  label: kind: NodeB
        NodeB2  label: kind: NodeB
        NodeB3  label: kind: NodeB

    nodeSelector:    
          kind: NodeA
          kubernetes.io/hostname: NodeA2

We have "the" tag that allow to work with affinities... like seriously:

    affinity:

That tag allows to specify 3 different kind of affinities:
- Pod Affinities            Kubernetes I prefer (or actually it's mandatory) that you place my pod in a node which contains pods compatible with the supplied specs
- Pod AntiAffinities*       Kubernetes I prefer (or actually it's mandatory) that you place my pod in a node which contains no pods compatible with the supplied specs
- Node Affinities           Kubernetes I prefer (or actually it's mandatory) that you place my pod in a node compatible with the supplied specs


      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:                        # mandatory rule
            nodeSelectorTerms:
            - matchExpressions:
              - key: topology.kubernetes.io/zone
                operator: In                                                    In NotIn Exists DoesNotExists  Gt Lt
                values:
                - antarctica-east1
                - antarctica-west1
          preferredDuringSchedulingIgnoredDuringExecution:                       # preference
          - weight: 1
            preference:
              matchExpressions:
              - key: another-node-label-key
                operator: In
                values:
                - another-node-label-value
          - weight: 2
            preference:
              matchExpressions:
              - key: another-node-label-key
                operator: In
                values:
                - another-node-label-value
                
    affinity:           
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:                        # mandatory rule
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/hostname: 
                operator: In                                                    In NotIn Exists DoesNotExists  Gt Lt
                values:
                - NodeA2
    nodeName: NodeA2
    nodeSelector:                                                               <<<< This is widely used
        kubernetes.io/hostname: NodeA2
        
    
# Pod affinity

    POD3
    affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - db
            topologyKey: kubernetes.io/hostname
      
    I want my pod in a node which contains a pod with label app = db
    
    Cluster  
        Node1  kubernetes.io/hostname=Node1            client=A
            pod1    app: db
            pod3
            pod4
        Node2  kubernetes.io/hostname=Node2            client=A
            pod2    app: webserver
            pod4
        Node3  kubernetes.io/hostname=Node3            client=B
        Node4  kubernetes.io/hostname=Node4            client=B
        
        Node5  client=B
            pod9    app:db
            pod10   app:webserver

    POD B1      antiaffinity IN label=db  topologyKey: hostname          cannot be deployed in node5   because it generates antiaffinity with app:db pod9
    POD B2      affinity NOT label=db  topologyKey: hostname             can be deployed on node5      because it generates affinity     with app:webserver pod 10

    POD4
    affinity:
        podAntiAffinity:                                                        <<< we do really use this kind of rule... actually as a preference
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - db
            topologyKey: kubernetes.io/hostname
            

    I want my pod in a node which contains a label client... so that any node containing the same label and value contains a pod with label app = db

    POD 5... such us pod3... but with NOTIN         node2, node3, node4
    POD 6... such us pod4... but with NOTIN         node3, node4.  (nodes with client=B)
    
    
    Imagine We have this situation:
    
    Cluster
        NodeA
            POD-WP-APACHE-1
        NodeB
            POD-WP-APACHE-2
            POD-WP-APACHE-4
        NodeC
            POD-WP-APACHE-3
        
    And I do want to deploy a wordpress application. I want 3 replicas of apache webserver
        POD-WP-APACHE-1
        POD-WP-APACHE-2
        POD-WP-APACHE-3
        POD-WP-APACHE-4

    We don't want that scenario... If node2 goes offline... I will lose my 3 pods.
    We can avoid this situation by using an anitaffinity rule... between the same kind of pods.