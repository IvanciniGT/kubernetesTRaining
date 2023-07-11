How many pods do we want to create inside a kubernetes cluster? 0 No one

Why? we don't want to create containers ourselfs
Kubernetes is the one who is going to create containers inside the cluster

In order to do this... I cannot create a POD... but to provide to kubernetes a POD TEMPLATE

# Object that allow to define a pod template:

- Deployment

A pod template + a number of replicas 

- Statefulset
- Daemonset