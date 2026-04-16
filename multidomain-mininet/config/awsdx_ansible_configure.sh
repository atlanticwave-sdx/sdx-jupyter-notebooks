#!/bin/bash

{

ANSIBLE_VENV="ansible-660"
python3 -m venv $ANSIBLE_VENV --upgrade-deps
source $ANSIBLE_VENV/bin/activate
python3 -m pip install ansible==6.6.0
python3 -m pip install argcomplete
python3 -m pip install netaddr
activate-global-python-argcomplete --dest ~/${ANSIBLE_VENV}/



cat << EOF >> ~/.bashrc
ANSIBLE_ROOT="\$HOME/awsdx-ansible"
INVENTORY="\$ANSIBLE_ROOT/awsdx-hosts"
PLAYBOOK="\$ANSIBLE_ROOT/site.yml"
export INVENTORY PLAYBOOK ANSIBLE_ROOT
EOF


cat << EOF >> ~/.bashrc
LC_ALL="C.UTF-8"
export LC_ALL
EOF

cat << EOF >> ~/.bashrc
source ~/ansible-660/bin/activate
cd \$ANSIBLE_ROOT
EOF

} 2>&1 > /var/tmp/awsdx_ansible_configure.log

