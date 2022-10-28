
#!/bin/bash

apt update -y && apt upgrade -y && apt autoremove -y

# stop service
sudo systemctl stop erigon

# delete new v2.28.1 version 
sudo rm -rf /usr/local/bin/erigon

# download and install stable v2.27.0
cd ~
curl -LO https://github.com/ledgerwatch/erigon/archive/refs/tags/v2.27.0.tar.gz
tar xvf v2.27.0.tar.gz
cd erigon-2.27.0
make erigon
cd ~
sudo mv erigon-2.27.0 /usr/local/bin/erigon

# remove the download leftovers
rm v2.27.0.tar.gz

# set (reconfirm again) ownership for erigon
chmod +x /usr/local/bin/erigon
sudo chown -R erigon:erigon /var/lib/erigon

# start service
sudo systemctl restart erigon

# check status
sudo systemctl status erigon

# check logs
sudo journalctl -fu erigon
