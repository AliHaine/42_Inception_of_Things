#!/bin/bash

export PATH="$HOME/bin:$PATH"

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
kubectl apply -n argocd -f /vagrant/argo.yml

until kubectl get svc will -n dev >/dev/null 2>&1; do
    sleep 1
done

echo "Waiting for will app to be ready..."
kubectl wait --namespace dev --for=condition=Available deployment will --timeout=320s

echo "Setup complete."