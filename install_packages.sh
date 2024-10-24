#!/bin/bash

# Check if the user is root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

# Update the package list
apt update
apt dist-upgrade

# Install the packages
PACKAGES="qemu-guest-agent openssh-serve"
apt install -y $PACKAGES

# Start Services
systemctl start qemu-guest-agent
systemctl enable qemu-guest-agent
sudo systemctl enable ssh --now

# Install Zabbix Agent
# Add the Zabbix repository:
sudo wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu24.04_all.deb 
sudo dpkg -i zabbix-release_7.0-2+ubuntu24.04_all.deb
sudo apt update

# Install the Zabbix Agent package:
sudo apt install zabbix-agent -y

# Configure Zabbix Agent (Debian)
# Edit the Zabbix Agent configuration file:
############################################################################################
sudo sed -i -E "s/^Server=127.0.0.1/Server=192.168.1.163/" /etc/zabbix/zabbix_agentd.conf
############################################################################################

# Restart the Zabbix Agent service:
sudo systemctl restart zabbix-agent
sudo /etc/init.d/zabbix-agent restart
sudo systemctl status zabbix-agent.service

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# install docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo docker run hello-world

#Docker start the docker daemon
sudo systemctl start docker

#To enable the Docker daemon to start on boot
sudo systemctl enable docker

#To verify that the Docker daemon is running, use the following command:
sudo systemctl status docker

#Docker-Compose Install

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

## Starting docker-compose on port 53 on Ubuntu##
#error: 
#edit: /etc/system/resolved.conf

# * uncomment: DNSStubListener=yes
# restart service: sudo systemctl restart systemd-resolved

# Check for any installation errors
if [ $? -ne 0 ]; then
  echo "Error installing packages."
  exit 1
fi

echo "Packages installed successfully."
