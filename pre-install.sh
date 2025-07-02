##vagrant
cd ~
wget https://releases.hashicorp.com/vagrant/2.4.1/vagrant_2.4.1_linux_amd64.zip
unzip vagrant_2.4.1_linux_amd64.zip -d ~/vagrant
echo 'export PATH="$HOME/vagrant:$PATH"' >> ~/.zshrc
source ~/.zshrc
vagrant --version

##k3d
mkdir -p ~/bin
export PATH="$HOME/bin:$PATH"
source ~/.bashrc
curl -Lo ~/bin/k3d https://github.com/k3d-io/k3d/releases/latest/download/k3d-linux-amd64
chmod +x ~/bin/k3d
k3d version

##kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
mkdir -p ~/bin
mv ./kubectl ~/bin/kubectl
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
kubectl version --client