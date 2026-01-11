#!/bin/bash

{
sudo dnf install -y vim git

sudo groupadd -g 2001 awsdx-admin
sudo useradd -g 2001 -u 2001 awsdx-admin

sudo mkdir /home/awsdx-admin/.ssh
sudo chown -R awsdx-admin. /home/awsdx-admin/.ssh


[ -f ./id_rsa ] && sudo mv ./id_rsa /home/awsdx-admin/.ssh/id_rsa
[ -f ./id_rsa.pub ] && cat ./id_rsa.pub >> ~/.ssh/authorized_keys && sudo mv ./id_rsa.pub /home/awsdx-admin/.ssh/id_rsa.pub

sudo chown awsdx-admin. /home/awsdx-admin/.ssh/id_rsa
sudo chown awsdx-admin. /home/awsdx-admin/.ssh/id_rsa.pub
sudo chmod 400 /home/awsdx-admin/.ssh/id_rsa

WHICHVM=$(hostname | grep -wo monitor)
if [ "${WHICHVM}" == "monitor" ]; then

#
# Python 3
#

python3_version="3.9.10"
python3_binary_file="python3.9"
pip3_binary_file="pip3.9"

python3_package="Python-${python3_version}.tgz"
download_from="https://www.python.org/ftp/python/${python3_version}"
pip3_download_from="https://bootstrap.pypa.io/get-pip.py"

sudo dnf install -y gcc openssl-devel bzip2-devel libffi libffi-devel wget yum-utils vim make zlib-devel

sudo wget  ${download_from}/${python3_package}
sudo mv ${python3_package} /usr/src
cd /usr/src
sudo tar xf ${python3_package}
yes | sudo rm  ${python3_package}
cd /usr/src/Python-${python3_version}
sudo ./configure --enable-optimizations
sudo make altinstall

cd /usr/local/bin
[ -L python3 ] && sudo rm -f python3
sudo ln -s ${python3_binary_file} python3

cd /usr/src
sudo curl ${pip3_download_from} -o get-pip.py
python3 get-pip.py

fi

} 2>&1 > /var/tmp/awsdx_node_configure.log
