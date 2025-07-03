echo "Running agent script.."

MASTER_IP=$1 
TOKEN=$(cat /vagrant/token)

echo "Server ip: $MASTER_IP"
echo "Token : $TOKEN"

echo "Download k3s.."
export K3S_URL="https://${MASTER_IP}:6443"
export K3S_TOKEN="${TOKEN}"
export INSTALL_K3S_EXEC="--node-ip 192.168.56.111"

curl -sfL https://get.k3s.io | sh -
