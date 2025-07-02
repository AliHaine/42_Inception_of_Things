echo "Running controller script.."

echo "Download k3s.."
curl -sfL https://get.k3s.io | sh -
sudo mkdir -p /home/vagrant/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube/config
TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
echo $TOKEN > /vagrant/token

echo "Generated Token : $TOKEN"

