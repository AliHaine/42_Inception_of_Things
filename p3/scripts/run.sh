#!/bin/bash

#Create cluster and namespace

if k3d cluster get maincluster >/dev/null 2>&1; then
    k3d cluster delete maincluster
fi

k3d cluster create maincluster -p "8080:80@loadbalancer"
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
kubectl port-forward svc/argocd-server -n argocd 8081:80 >/dev/null 2>&1 &

#Wait for port stabilization
sleep 5

#Apply my argo manifest
echo "Applying argocd custom manifest"
kubectl apply -n argocd -f argo.yml

until kubectl get svc will -n dev >/dev/null 2>&1; do
    sleep 1
done

echo "Waiting for will app to be ready..."
kubectl wait --namespace dev --for=condition=Available deployment will --timeout=120s

# Port-forward in background for will app
echo "Starting port-forward to will app..."
kubectl port-forward svc/will -n dev 8888:80 >/dev/null &

echo "Setup complete."
echo "You can access ArgoCD GUI at https://localhost:8081"
echo "You can access will app at https://localhost:8888"