---
all:
  hosts:
    '${ host_ip }': # this is a var
        ansible_become: yes
        ansible_connection: ssh
        ansible_python_interpreter: /usr/bin/python
  vars:
    ansible_ssh_user: ${ user_id }
    host_key_checking: False
    kubectl_version: "${ k8s_version }"
    # base64 encoded
    kube_conf_content: "${ kubeconf_content }"
