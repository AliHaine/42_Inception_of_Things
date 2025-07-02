curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644
sudo mkdir -p /home/vagrant/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube/config

echo "192.168.56.110 app1.com app2.com app3.com" | sudo tee -a /etc/hosts

sleep 10

kubectl apply -n kube-system -f ../../vagrant/app1.yml
kubectl apply -n kube-system -f ../../vagrant/app2.yml
kubectl apply -n kube-system -f ../../vagrant/app3.yml
kubectl apply -n kube-system -f ../../vagrant/controller.yml