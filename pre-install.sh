#!/bin/zsh

rm -rf ~/bin

mkdir -p ~/bin
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc

##vagrant
wget https://releases.hashicorp.com/vagrant/2.4.7/vagrant_2.4.7_linux_amd64.zip
unzip vagrant_2.4.7_linux_amd64.zip -d ~/bin
sleep 1
rm -rf ./vagrant_2.4.7_linux_amd64.zip

##k3d
curl -Lo ~/bin/k3d https://github.com/k3d-io/k3d/releases/download/v5.8.3/k3d-linux-amd64
chmod +x ~/bin/k3d

##kubectl
curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o ~/bin/kubectl
chmod +x ~/bin/kubectl

vagrant --version
k3d version
kubectl version --client