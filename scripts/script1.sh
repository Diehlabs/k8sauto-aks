#!/bin/bash
sudo curl -LO https://dl.k8s.io/release/${var.k8s_version}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl

echo "test:"
ls -la /usr/local/bin

if [[ -d \"/usr/local/bin\" ]];
then
    sudo mkdir /usr/local/bin
fi

sudo chmod +x /usr/local/bin/kubectl

if [[ -d \"/home/adminuser/.kube\" ]];
then
    mkdir /home/adminuser/.kube
fi


curl -LO https://dl.k8s.io/release/1.21.1/bin/linux/amd64/kubectl -o /tmp/kubectl