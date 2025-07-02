echo "Running agent script.."

MASTER_IP=$1 
TOKEN=$(cat /vagrant/token)

echo "Server ip: $MASTER_IP"
echo "Token : $TOKEN"

echo "Download k3s.."
if curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 K3S_TOKEN=$TOKEN sh - ; then
    echo "k3s ready to be used"
else
    echo "k3s installation failed"
    exit 1
fi