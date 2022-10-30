#!/bin/bash

apt update -y && apt upgrade -y && apt autoremove -y

sudo systemctl stop erigon
sudo rm -rf /usr/local/bin/erigon

cd $HOME
curl -LO https://github.com/ledgerwatch/erigon/archive/refs/tags/v2.27.0.tar.gz
tar xvf v2.27.0.tar.gz
cd erigon-2.27.0
make erigon

cd $HOME
sudo mv erigon-2.27.0 /usr/local/bin/erigon

rm v2.27.0.tar.gz

chmod +x /usr/local/bin/erigon
sudo chown -R erigon:erigon /var/lib/erigon

sudo systemctl restart erigon

sudo journalctl -fu erigon
