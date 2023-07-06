# Kubernetes

Kubernetes is not a single program, but a bunch of them.
- Need to be installed on top of the host OS:
    - kubeadm           Allows us to manage a kubernetes cluster (create, delete a cluster, add nodes...)
    - kubectl           Allows us to interact with a running Kubernetes cluster
    - kubelet           Is a service that needs to be instyalled in every node within the cluster
                        It's responsible of the container manager (CRIO) control.
- There are more programs (components) that are goping to be installed inside the actual cluster as containers:
    Kubernetes Control Plane:
        - Kubernetes database: ETCD
        - Kubernetes DNS Server
        - Kubernetes API Manager
        - Kubernetes scheduller. This one decides where (in which node) a new pod is going to be deployed
        - Kubernetes proxy: This one manages netFilter Rules on each host
        - ...

We are still missing a Virtual Network Driver.


------------------------------------------------------------ Company Network
 |
 |=192.168.0.101-Node 1
 ||                 |-10.10.0.101-Container 1 - Web server
 ||
 |=192.168.0.102-Node 2
 ||                 |-10.10.0.102-Container 2
 ||
 ||=192.168.0.103-Node 3
 |                  |-10.10.0.103-Container 3 - Database
 |                  |-10.10.0.104-Container 4
 |
 
 
 # Interacting with kubernetes
 
 Kubernetes will take care of our production environment.
 But we neet to teach, to tell Kubernetes how do we want that work done.
 
 Good news are that we are not going to actually explain kubernetes what it needs to do: We are not going to use an IMPERATIVE LANGUAGE
 We are justo going to tell Kubernetes what we want in the cluster... And Kubernetes ig going to determine and decide 
 what needs to be done: WE ARE GOING TO USE A DECLARATIVE LANGUAGE
 
 All we are going to do is to add configurations to our cluster.
 - I want this and that...
 
There are a bunch of configurations (settings, OBJECTS) that we can create in our cluster
We are going to describe those things inside YAML files.
Right after that, we will supply those YAML files to Kubernetes... and Kubernetes is going to take care of the cluster ... and is going to apply those configurations.

---

# Objects that we can create / Manage in our cluster:

- Namespace
    - Pod
    - PodTemplates:
        - StatefulSet
        - Deployment: Pod Template + initial number of replicas
        - DaemonSet: Pod template (Kubernetes is going to create 1 pod per host, using that template)
    - ConfigMap
    - Secret
    - PersistentVolumeClaim
    - NetworkPolicy
    - Service
    - Ingress
- PersistentVolume
- ...


** One amazing thing about kubernetes is that we can install 
more kind of objects... to extends Kubernetes functionality

- SSL Certificate
- SSL Certificate Request

Kubertenes comes with about 25 kinds of objects by default.

But there are a bunch of Kubernetes distributions (software packages extending kubernetes):
- Openshift is the Redhat Kubernetes distribution (comes with more that 200 different objects)
- Tamzu is the VMWare Kubernetes distibution  (comes with more that 200 different objects)

In order to install adittional object types we hace to install new libraries inside the cluster.
Each library is going to have its own ID/version
Inside each library (ID/version) we will have OBJECT TYPES

# kubectl

This is the kubernetes client.
With this command we will be able to:
- supply YAML files to Kubernetes
- query what objects (configurations) do we have... and its status
- ...

## Syntax

$ kubectl [VERB]      [OBJECT_TYPE]                          <extra args>
          get         namespaces namespace ns                   -n, --namespace NAMESPACE_NAME
          describe    pods pod
                      persistentvolumeclaim pvc
                      services service   srv

$ kubectl create -f [YAML_FILE_PATH]
        This command creates in our cluster all the objects specified in the supplied file
        
$ kubectl delete -f [YAML_FILE_PATH]
        This command deleted from our cluster all the objects specified in the supplied file
        
$ kubectl apply -f [YAML_FILE_PATH]
        This command creates or updates in our cluster all the objects specified in the supplied file
        
---

# Namespaces

A namespace is just a logical division of the cluster.
Inside a Kubernetes cluster, we can have a bunch of namespaces.
Objects (configurations), aplications,... are always created inside ONE namespace.
If no namespace is supplied when creating an object, that object will be assigned to de "default" namespace.
Actually, the default namespace is just another namespace.
We never use the deafult ns... Thats a horrible practice.
In Kubernetes we will be able to create user accounts. We can restrict users to access only to certain Namespaces.

We use namespaces for different purposes:
- Different environment:
    - app1.dev.env < NS
    - app1.test.env < NS
    - app1.prod.env < NS
- Different aplicacions
    - app1
    - app2
    - app3

# Pods

Pod is the main concept (objecto) that we are going to manage in kubernetes.
   
In Kubernetes we deploy pods.

A container is an isolated env. inside a Linux OS where we run process.
Containers are created from container images... that contain a software already install and preconfigured.

In kubernetes we cannot deploy containers... always we deploy pods.

A pod is a set of containers, that:
- They share network configuration
- They are going to be deployed on the same host
- They may share local volumes (that can share files)
- They scale together
        
        
---

# During the training:

Node1 (server that we rent in Amazon)
    - Kubernetes
    - We are using this server as our development server
    - We are using this server as the environment that we use to configure the cluster
    
In a real environment:
    - A cluster with 50-100 nodes
        ^^
    - An environment (a different computer) that you are going to use to exec kubectl apply ....
        vv
        git repository
        ^^
    - Developers will create YAML files in their laptops...


2 cluster for production  ... Are a replica of each other in 2 different loactions
2 cluster for pre-production

In a real kubernetes cluster we will have:
At least 3/5 hosts just to run the kubernetes control-plane
Nodes executing the control plane of kubernetes (pods with any or some of the main kubernetes progremas - scheduler, db, dns server...-)
They don't allow by default to execute any other kind of pod. They are protected.

With this command:
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

We remove that restriction...
WE DON'T WANT TO EXECUTE THAT IN A REAL CLUSTER.


My Kubernetes production cluster:
    Control plane nodes:
    - Node 1 
        kubelet
            crio
        control-manager
    - Node 2
        kubelet
            crio
        scheduler
    - Node 3
        kubelet
            crio
    ------
    Working nodes:
    - Node 50
        kubelet
            crio
    - Nodo 100  ***
        kubelet
            crio < pull the image
                   create the container

---

In order to execute additional process inside a container I can execute:;
$ kubectl exec my-first-pod -n my-namespace -c container1 -- COMMAND