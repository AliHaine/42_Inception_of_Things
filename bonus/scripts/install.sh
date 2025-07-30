#!/bin/bash

sudo apt-get update -y
export PATH="$HOME/bin:$PATH"
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc

#docker

sudo apt-get install docker.io -y

sudo usermod -aG docker $USER
newgrp docker

docker --version

##k3d
curl -Lo k3d "https://github.com/k3d-io/k3d/releases/download/v5.8.3/k3d-linux-amd64"
chmod +x k3d
mv k3d /usr/local/bin/k3d

##kubectl
mkdir -p ~/bin
curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o ~/bin/kubectl
chmod +x ~/bin/kubectl

k3d version
kubectl version --client