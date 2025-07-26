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
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

##kubectl
mkdir -p ~/bin
curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o ~/bin/kubectl
chmod +x ~/bin/kubectl

k3d version
kubectl version --client

#Create cluster and namespace

if k3d cluster get maincluster >/dev/null 2>&1; then
    k3d cluster delete maincluster
fi

k3d cluster create maincluster -p "8080:80@loadbalancer" -p "8888:8888@loadbalancer" 
kubectl create namespace argocd
kubectl create namespace dev

#Install the argocd application
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD components to be ready..."
kubectl wait --namespace argocd --for=condition=Available deploy --all --timeout=380s

echo "\nArgoCD Admin Password:\n"
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
echo "\n"

#Wait for port stabilization
sleep 5

# Port-forward in background
echo "Starting port-forward to ArgoCD GUI..."
kubectl port-forward svc/argocd-server -n argocd 8080:80 >/dev/null 2>&1 &

#Wait for port stabilization
sleep 5

# Apply ingress for will
kubectl apply -n dev -f /vagrant/ingress.yml

#Apply my argo manifest
echo "Applying argocd custom manifest"
kubectl apply -n argocd -f /vagrant/argo.yml

until kubectl get svc will -n dev >/dev/null 2>&1; do
    sleep 1
done

echo "Waiting for will app to be ready..."
kubectl wait --namespace dev --for=condition=Available deployment will --timeout=320s

#Wait for port stabilization
sleep 5

echo "Setup complete."