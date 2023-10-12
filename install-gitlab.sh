#!/bin/bash

# Check if a domain is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <your-domain.com>"
    exit 1
fi

# Step 1: Install Ansible
sudo apt-get update
sudo apt-get install -y ansible

# Step 2: Create inventory file
cat << EOF > inventory.ini
[local]
127.0.0.1 ansible_connection=local
EOF

# Step 3: Create the Ansible playbook file
cat << EOF > install_software.yml
---
- name: Install software on localhost
  hosts: 127.0.0.1
  connection: local
  become: yes  # This is to run tasks as sudo
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes

    - name: Install dependencies
      apt:
        name:
          - curl
          - openssh-server
          - ca-certificates
          - tzdata
          - perl
        state: present

    - name: Install GitLab
      shell:
        cmd: |
          curl -LO https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh &&
          sudo bash script.deb.sh &&
          sudo EXTERNAL_URL="http://$1" apt-get install gitlab-ce

    - name: Ensure GitLab is running
      systemd:
        name: gitlab-runsvdir
        state: started
        enabled: yes
EOF

# Step 4: Run the Ansible playbook
ansible-playbook -i inventory.ini install_software.yml
