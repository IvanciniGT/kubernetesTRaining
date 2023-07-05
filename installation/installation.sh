# Uninstall docker

sudo apt purge docker-ce -y
sudo apt autoremove -y

# Kubernetes does not allow swapping
## Disable swap for this current OS session (start)
sudo swapoff -a
# Disable swap in future sessions (restarts) of the OS
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# First thing is to have a compatyible container manager installed: CRIO, Containerd

# Those commands are going to activate some modules in the Linux KErnel... to allow define and use virtual networks

sudo modprobe overlay
sudo modprobe br_netfilter


# We are going to define a virtual network for our containers... This si temporary... just to make CRIO worek.
# Once Kubernetes is installed... We will need to deploy real virtual network plugin...
# The one that we are going to configure right now... only works inside our server.Kubernetes requires a virtual 
# network that allows containes to communicate each other between different servers (physical servers)
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
# Lets apply that configuration
sudo sysctl --system

## Let's install crio:

# Let's store our OS version... and the target CRIO version inside a couple of vars
export OS=xUbuntu_18.04
export CRIO_VERSION=1.23

# That we are going to use to register the offitial CRIO REPOSITORIES (where crio is located so that we can download it)
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list

# HEre we just download the public Key of those repositorioes so that apt is able to double check the donwload to make sure that nobody did update those files (the crio installation) while downloading
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -

# We are ready to install CRIO
# This commmand is going to read those new REPOSITORIES, so that apt learns about CRIO
sudo apt update

# Let's install
sudo apt install cri-o cri-o-runc -y

# To tell apt to not update crio automatically
# Tell the system daemon to reaload services, to make sure that it learns about crio...
# And we will tell that systema daemon to start crio each time the server boots
apt-cache policy cri-o
sudo systemctl daemon-reload
sudo systemctl enable crio --now

# AT THIS POINT WE ARE IN SITUATION OF INSTALLING KUBERNETES.
# REQUIREMENTS ARE ALRADY SET UP

# We will need to add to apt the Kubenetes offitial repositories

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

# We will tell apt to install: kubelet kubeadm kubectl
sudo apt update # LEarn about kubernetes (what's in that repository)
sudo apt install kubeadm kubelet kubectl -y


#    KUBELET
#.   -v-^-----------------------------
#     CRIO : OUR CONTAINERS MANAGER
#    ----------------------------------
#            LINUX OS (Ubuntu)
#    ---------------------------------
#                   HOST
              
# kubeadm is a client that we will use when creating a cluster... also when adding new nodes (servers) to out cluster
# We use this tool to CONFIGURE THE KUBERNETES CLUSTER

# kubectl is the kubernetes client. This tool allows us (humans) to interact with the kubernetes cluster

# Initialize a cluster . This si going to download all kubernetes control plane software container images.
# Its is also going to create containers... and assign to those container IPs from a specific IP address poll,
# that will also be used in the future by the actual Virtual network that we are going to create.
sudo kubeadm init --pod-network-cidr=10.10.0.0/16