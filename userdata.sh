#!/bin/bash -v
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update -y
apt-cache policy docker-ce python-minimal python-pip
sudo apt-get install -y docker-ce python-minimal python-pip
sudo apt-get install -y nginx > /tmp/nginx.log
pip install docker-py
