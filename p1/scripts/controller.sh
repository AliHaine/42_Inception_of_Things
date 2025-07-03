echo "Running controller script.."

echo "Download k3s.."
export INSTALL_K3S_EXEC="--node-ip 192.168.56.110 --write-kubeconfig-mode 644"
curl -sfL https://get.k3s.io | sh -
TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
echo $TOKEN > /vagrant/token

echo "Generated Token : $TOKEN"

