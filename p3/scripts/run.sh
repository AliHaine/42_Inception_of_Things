#!/bin/bash

#Create cluster and namespace
k3d cluster create maincluster -p "8080:80@loadbalancer"
kubectl create namespace argocd

#Install the argocd application
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD components to be ready..."
kubectl wait --namespace argocd --for=condition=Available deploy --all --timeout=380s

echo "ArgoCD Admin Password:"
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
echo ""

#Wait for port stabilization
sleep 5

# Port-forward in background
echo "Starting port-forward to ArgoCD GUI..."
kubectl port-forward svc/argocd-server -n argocd 9090:80 > /dev/null &

#Wait for port stabilization
sleep 5

#Apply my argo manifest
kubectl apply -n argocd -f configs/argo.yml

# Port-forward in background for will app
echo "Starting port-forward to will app..."
kubectl port-forward svc/will -n dev 8888:80 > /dev/null &

echo "Setup complete. You can access ArgoCD at https://localhost:8080"