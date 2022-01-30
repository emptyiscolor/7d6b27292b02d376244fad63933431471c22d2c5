#!/bin/bash

curl https://raw.githubusercontent.com/wklken/vim-for-server/master/vimrc > /root/.vimrc && \
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add - && \
    wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add - && \
    echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | \
         sudo tee -a /etc/apt/sources.list.d/virtualbox.list && \
    sudo apt update && sudo apt install virtualbox-6.1 && \
    wget -c https://download.virtualbox.org/virtualbox/6.1.32/Oracle_VM_VirtualBox_Extension_Pack-6.1.32.vbox-extpack && \
    yes | sudo VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-6.1.32.vbox-extpack

# sudo apt install xfce4 xfce4-goodies
# https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-vnc-on-ubuntu-20-04

