# Containers

Are just an isolated environment where I can run processes.

Isolated environment: Each container is going to have
- its own network configuration -> Its own IP(s) address(es)
- its own file system (kind a hdd) to store its files and folders
- its own environment variables
- may have limits in the usage of the physical resources (Memory, CPU...) from the host

Inside that filesystem... we are not going to see a linux Kernel

We create containers from Container images.

## Container image

Imagine I want to install MySQL on my Windows computer:

0 - We need to make sure that our host meets the requirements needed to install taht software
1 - Download an installer 
2 - Execute that installer.. / configuration: Depending on the software this process can be less or more complicated.

 -> c:\Program filesx86\MySQLServer -> .zip -> email ---> decompress
                                         |
                                         v
                                         
                                         This is what we call a Container Image... kind of...
                                         
A container image is just a compressed file (tar) which includes a software ALREADY INSTALLED,
including a default configuration... and all the required dependencies already installed too.

We just need to decompress that tar file... And we are ready to go!
Nowadays Container images are the standart way of sharing sofware.
EVERY SINGLE business software is distributed nowadays thru container images

We can loog for Container images in Container Images Repositories Registries.
The most relevant one is called Docker HUB.


-----


------------------------------------------------------------------ My company network
 |
 ||= Server1
 ||    |- containerA
 ||    |- containerB
 ||    |- containerS
 ||
 ||
 ||= Server2
 ||    |- containerA1
 ||    |- containerB1
 ||    |- containerS1
 ||
 ||
 ||= Server3
 |    |- containerA5
 |    |- containerB5
 |    |- containerS5
 |
 
 We will need to install a software to create and manage that shared Virtual network.
 That software is going to be installed actually inside the kubernetes cluster... as more containers.
 The point is that we won't be able to install that program (Virtual network driver) until having a running kubernetes cluster.
 
 At the same time... we cannot create an actual Kubernetes cluster wihtout having a virtual network.
 
 There is a trick...
 We will install the software which is going to create the VNetwork LATER....
 But we will crate a cluster right now... letting Kubernetes know the IP_POLL that that network is going to use in the future
 
 
 
------------------------------------------------------------------ My company network
 |
 |- Server1
 |    |- 10.10.0.2 kubernetes DB              |
 |    |- 10.10.0.3 kubernetes DNS             |
 |    |- 10.10.0.4 kubernetes scheduller      |   Kubernetes control-plane
 |    |- 10.10.0.5 Kubernetes api manager     |
 |    |- ...                        |
 |
 
 
 CIDR: 10.10.0.0/16
        10.10.0.2
        10.10.0.56
        10.10.100.1
        