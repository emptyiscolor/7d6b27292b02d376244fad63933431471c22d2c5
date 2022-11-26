#!/bin/bash

# Ask for the user password

# Install kernel extra's to enable docker aufs support
sudo apt-get -y install linux-image-extra-$(uname -r)

# Add Docker PPA and install latest version
# sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
# sudo sh -c "echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
# sudo apt-get update
# sudo apt-get install lxc-docker -y

# Alternatively you can use the official docker install script
wget -qO- https://get.docker.com/ | sh

# Install docker-compose
COMPOSE_VERSION=`git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oE "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1`
sudo sh -c "curl -L https://github.com/docker/compose/releases/download/v2.13.0/docker-compose-linux-x86_64 > /usr/local/bin/docker-compose > /usr/local/bin/docker-compose"
sudo chmod +x /usr/local/bin/docker-compose

# move to larger space
sudo systemctl stop docker &&\
    sudo mkdir -p /mydata/docker &&\
    sudo rm -rf /var/lib/docker &&\
    sudo ln -s /mydata/docker /var/lib/ &&\
    sudo systemctl start docker

# Install docker-cleanup command
cd /tmp
git clone https://gist.github.com/76b450a0c986e576e98b.git
cd 76b450a0c986e576e98b
sudo mv docker-cleanup /usr/local/bin/docker-cleanup
sudo chmod +x /usr/local/bin/docker-cleanup

sudo apt install -y python3-pip python3.8-dev python3.8-venv build-essential byobu

