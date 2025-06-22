# Project Inception of Things from Ecole 42 

_This project focuses on deepening Kubernetes knowledge by using K3d and K3s with Vagrant. It involves setting up a personal virtual machine with Vagrant and a Linux distribution, followed by the configuration of K3s and its Ingress system. Finally, it introduces K3d as a tool to simplify local Kubernetes cluster management._

|Command|Description|
|----------|----------|
|vagrant up|Starts the VM using the configuration in the Vagrantfile|
|vagrnt halt|Shuts down all VM managed by the current Vagrantfile|
|vagrnt provision|Runs provisioners (scripts) without reboooting VM|
|vagrant destroy [name]|Destroys and removes the specified VM|
|vagrant status [name]|Display the status and revelant info about the managed VM|
|vagrant ssh [hostname]|Connect with SSH to the specified VM|
|kubectl get pods|Display all pods|
|kubectl get ingressclass|Display the available ingressClass|
|kubectl get endpoints|Display ip and ports of pods|
|kubectl get svc|Display all the services|
|kubectl logs -n [name_space] [pod_name]|Display the target logs|
|kubectl delete [type] [name] -n [name_space]|Delete the target element|
|kubectl describe [type] [name]|Display health and aditional informations|
|kubectl apply -f [file_conf] |Update kubernetes based on the specified config|

_--all-namespaces option is usable to avoid name_space specification_

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

Each app will have a Service linked to a specific Deployment. Here’s a simple service configuration:

```
apiVersion: v1
kind: Service                # Type of Kubernetes resource
metadata:
  name: app1                 # Service name, used by the Deployment to target the Service
spec:
  selector:
    app: app1                # Selects the Pods with label 'app: app1'
  ports:
    - protocol: TCP
      port: 80               # Service port (accessible by other resources)
      targetPort: 8080       # Port exposed by the container inside the Pod
```

Now, a Deployment is needed to run the Pods:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1
  labels:
    app: app1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app1
  template:
    metadata:
      labels:
        app: app1
    spec:
      containers:
        - name: hello-kubernetes
          image: paulbouwer/hello-kubernetes:1.10
          env:
          - name: MESSAGE
            value: "Hello from app1."
          ports:
            - containerPort: 8080
```

Finally, traffic is managed by an Ingress (using Traefik (default) in this example):

```
spec:
  ingressClassName: traefik
  rules:
  - host: app1.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1
            port:
              number: 80
```

This configuration means:
Everything sent to app1.com at the root path / will be redirected to the Service named app1 on port 80

Then, the service will look to a deployment with name 'app1'

## Part 3

## Bonus
