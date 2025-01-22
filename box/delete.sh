#!/bin/bash
sudo systemctl stop erigon
sudo systemctl stop lighthousebeacon

sudo systemctl disable erigon
sudo systemctl disable lighthousebeacon

sudo rm -rf /etc/systemd/system/erigon.service
sudo rm -rf /etc/systemd/system/lighthousebeacon.service

sudo rm -rf /var/lib/jwtsecret
sudo rm -rf /usr/local/bin/erigon
sudo rm -rf /var/lib/erigon

sudo rm -rf /usr/local/bin/lighthouse
sudo rm -rf /var/lib/lighthouse
