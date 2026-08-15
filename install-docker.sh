#!/bin/bash

# Ask for the user password

# Install kernel extra's to enable docker aufs support
# sudo apt-get -y install linux-image-extra-$(uname -r)

# Add Docker PPA and install latest version
# sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
# sudo sh -c "echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
# sudo apt-get update
# sudo apt-get install lxc-docker -y

# Alternatively you can use the official docker install script
wget -qO- https://get.docker.com/ | sh

# Install docker-compose
# COMPOSE_VERSION=`git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oE "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1`
# sudo sh -c "curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
# sudo chmod +x /usr/local/bin/docker-compose
# sudo sh -c "curl -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"

# Install docker-cleanup command
cd /tmp
git clone https://gist.github.com/76b450a0c986e576e98b.git
cd 76b450a0c986e576e98b
sudo mv docker-cleanup /usr/local/bin/docker-cleanup
sudo chmod +x /usr/local/bin/docker-cleanup

sudo systemctl stop docker &&\
    sudo mkdir -p /mydata/docker &&\
    sudo rm -rf /var/lib/docker &&\
    sudo ln -s /mydata/docker /var/lib/ &&\
    sudo systemctl start docker

sudo mkdir -p /mydata/data

sudo apt install -y python3-pip build-essential byobu stress-ng htop

sudo bash /local/repository/install-frps.sh install

sudo bash /local/repository/f_config.sh

U=$(ls /users | tail -n1)
echo "User: $U"
sudo chown -R $U /mydata/data
sudo -u "$U" nohup python3 /local/repository/sine.py >/var/tmp/sine.log 2>&1 </dev/null &
sudo usermod -aG docker $U || echo "User already in docker group"
sudo /local/repository/setup-linux-kernel-dev.sh --user "$U" --skip-docker

HOME_DIR=$(getent passwd "$U" | cut -d: -f6)
SSH_DIR="${HOME_DIR}/.ssh"
KEY_FILE="${SSH_DIR}/id_ed25519"
sudo -u "$U" mkdir -p "$SSH_DIR"
sudo -u "$U" chmod 700 "$SSH_DIR"
if [ ! -f "$KEY_FILE" ]; then
    sudo -u "$U" ssh-keygen -t ed25519 -N "" -f "$KEY_FILE" -q
fi

echo "Installation complete"