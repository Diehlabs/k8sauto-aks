#!/bin/bash
echo "test:"
ls -la /usr/local/bin

if [[ -d \"/usr/local/bin\" ]];
then
    sudo mkdir /usr/local/bin
fi

sudo curl -LO https://dl.k8s.io/release/${k8s_ver}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
sudo chmod +x /usr/local/bin/kubectl

if [[ -d \"/home/adminuser/.kube\" ]];
then
    mkdir /home/adminuser/.kube
fi


curl -LO https://dl.k8s.io/release/1.21.1/bin/linux/amd64/kubectl -o /tmp/kubectl