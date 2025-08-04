#!/bin/bash

sudo apt-get update -y
export PATH="$HOME/bin:$PATH"
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc

#docker

sudo apt-get install docker.io -y

sudo usermod -aG docker $USER

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

#Create cluster and namespace
k3d cluster create maincluster -p "8080:80@loadbalancer" -p "8888:31888@loadbalancer"
  
kubectl create namespace argocd
kubectl create namespace dev

#Install the argocd application
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

#Disable https only (allow unsafe mode)
kubectl -n argocd patch deployment argocd-server \
  --type='json' \
  -p='[
    {"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--insecure"},
    {"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--disable-auth"}
]'

echo "Waiting for ArgoCD server to be ready..."
kubectl rollout status deployment argocd-server -n argocd

#Apply my argo manifest
echo "Applying argocd custom manifest"
if [ -f /vagrant/argo.yml ]; then
  kubectl apply -n argocd -f /vagrant/argo.yml
else
  kubectl apply -n argocd -f /vagrant/confs/argo.yml
fi

until kubectl get svc will -n dev >/dev/null 2>&1; do
    sleep 1
done

echo "Waiting for will app to be ready..."
kubectl wait --namespace dev --for=condition=Available deployment will --timeout=320s

echo "Setup complete."