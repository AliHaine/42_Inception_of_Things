# Project Inception of Things from Ecole 42 

_This project focuses on deepening Kubernetes knowledge by using K3d and K3s with Vagrant. It involves setting up a personal virtual machine with Vagrant and a Linux distribution, followed by the configuration of K3s and its Ingress system. Finally, it introduces K3d as a tool to simplify local Kubernetes cluster management._

|Command|Description|
|----------|----------|
|vagrant up|Starts the VM using the configuration in the Vagrantfile|
|vagrnt halt|Shuts down all VM managed by the current Vagrantfile|
|vagrant destroy [name]|Destroys and removes the specified VM|
|vagrant status [name]|Display the status and revelant info about the managed VM|
|vagrant ssh [hostname]|Connect with SSH to the specified VM|
|kubectl get pods --all-namespaces|Display all pods|
|kubectl get ingressclass|Display the available ingressClass|
|kubectl get endpoints||
|kubectl get svc||

## Part 1 

_The Part 1 consists in setting up two virtual machines. A Vagrantfile must be written using the latest stable version of the chosen distribution as the OS. It is recommended to allocate only: 1 CPU and 512 MB. The machines must be run using Vagrant._

To complete Part 1, the first step is to install K3S and generate a token on the controller plane VM. This token will be used to authenticate all the VM in the cluster, without the right token, VM can't join the cluster.

**VM 1**

Controller plane script: installs k3s, generates the token, shares it though the vegrant shared folder, set permissions, run the 'controller mind', etc...

```
curl -sfL https://get.k3s.io | sh -
sudo mkdir -p /home/vagrant/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube/config
TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
echo $TOKEN > /vagrant/token
```

**VM 2**

Agent script: Requieres the controller plane's IP to connect, and uses the previously generated token to join the cluster.

```
MASTER_IP=$1 
TOKEN=$(cat /vagrant/token)
curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 K3S_TOKEN=$TOKEN sh -
```

**Vagrantfile configuration**

Simple example of one VM

```
config.vm.define "ayagmurS" do |node|
node.vm.hostname = "ayagmurS"
node.vm.network "private_network", ip: "192.168.56.110"
node.vm.provider "virtualbox" do |vb|
	vb.name = "ayagmurS"
	vb.memory = 512
	vb.cpus = 1
end
node.vm.provision "shell", path: "./scripts/controller.sh"
end
```

## Part 2

_Earlier we set up VMs but without any apps running on them. So, Part 2 concists in setting up several apps in single virtual machines_

Each 'apps' will be a service

## Part 3

## Bonus
