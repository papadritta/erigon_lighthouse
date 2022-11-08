#!/bin/bash
apt update -y && apt upgrade -y && apt autoremove -y

sudo systemctl stop erigon
sudo systemctl stop lighthousebeacon
sudo rm -rf /usr/local/bin/erigon
sudo rm -rf /usr/local/bin/lighthouse

cd $HOME
curl -LO https://github.com/ledgerwatch/erigon/archive/refs/tags/v2.29.0.tar.gz
tar xvf v2.29.0.tar.gz
cd erigon-2.29.0
make erigon

cd $HOME
sudo mv erigon-2.29.0 /usr/local/bin/erigon

rm v2.29.0.tar.gz

chmod +x /usr/local/bin/erigon
sudo chown -R erigon:erigon /var/lib/erigon

cd $HOME
curl -LO https://github.com/sigp/lighthouse/releases/download/v3.2.1/lighthouse-v3.2.1-x86_64-unknown-linux-gnu.tar.gz
tar xvf lighthouse-v3.2.1-x86_64-unknown-linux-gnu.tar.gz
sudo mv lighthouse /usr/local/bin

rm lighthouse-v3.2.1-x86_64-unknown-linux-gnu.tar.gz

chmod +x /usr/local/bin/lighthouse
sudo chown -R lighthousebeacon:lighthousebeacon /var/lib/lighthouse/beacon

sudo systemctl restart erigon
sudo systemctl restart lighthousebeacon



