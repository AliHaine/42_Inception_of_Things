curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644
sudo mkdir -p /home/vagrant/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube/config

sleep 15

kubectl apply -f ../../vagrant/app1.yml
kubectl apply -f ../../vagrant/app2.yml
kubectl apply -f ../../vagrant/app3.yml
kubectl apply -f ../../vagrant/controller.yml