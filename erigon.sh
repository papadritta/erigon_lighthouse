#!/bin/bash
exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
  echo ''
else
  sudo apt update && sudo apt install curl -y < "/dev/null"
fi
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi

source <(curl -s https://raw.githubusercontent.com/papadritta/scripts/main/main.sh)

printLogo

printCyan "Updating packages..." && sleep 1
apt update -y && apt upgrade -y && apt autoremove -y


printCyan "Installing dependencies..." && sleep 1
apt-get update && apt-get install -y git clang llvm ca-certificates curl build-essential binaryen protobuf-compiler libssl-dev pkg-config libclang-dev cmake jq

printCyan "Installing Golang..." && sleep 1
cd $HOME
cd ~
curl -LO https://go.dev/dl/go1.19.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.19.3.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
source $HOME/.profile
rm go1.19.3.linux-amd64.tar.gz

printCyan "Setting jwtsecret..." && sleep 1
cd $HOME
sudo mkdir -p /var/lib/jwtsecret
openssl rand -hex 32 | sudo tee /var/lib/jwtsecret/jwt.hex > /dev/null

printCyan "Installing Erigon..." && sleep 1
cd $HOME
curl -LO https://github.com/ledgerwatch/erigon/archive/refs/tags/v2.29.0.tar.gz
tar xvf v2.29.0.tar.gz
cd erigon-2.29.0
make erigon

cd $HOME
sudo mv erigon-2.29.0 /usr/local/bin/erigon
rm v2.29.0.tar.gz

sudo useradd --no-create-home --shell /bin/false erigon
sudo mkdir -p /var/lib/erigon
sudo chown -R erigon:erigon /var/lib/erigon

sudo tee /etc/systemd/system/erigon.service > /dev/null <<EOF
[Unit]
Description=Erigon Execution Client (Mainnet)
After=network.target
Wants=network.target
[Service]
User=erigon
Group=erigon
Type=simple
Restart=always
RestartSec=5
ExecStart=/usr/local/bin/erigon/build/bin/erigon \
  --datadir=/var/lib/erigon \
  --rpc.gascap=50000000 \
  --http \
  --ws \
  --rpc.batch.concurrency=100 \
  --state.cache=2000000 \
  --http.addr="0.0.0.0" \
  --http.port=8545 \
  --http.api="eth,erigon,web3,net,debug,trace,txpool" \
  --authrpc.port=8551 \
  --private.api.addr="0.0.0.0:9595" \
  --http.corsdomain="*" \
  --torrent.download.rate 90m \
  --authrpc.jwtsecret=/var/lib/jwtsecret/jwt.hex \
  --metrics 
[Install]
WantedBy=default.target
EOF

printCyan "Installing Lighthouse Beacon..." && sleep 1
cd $HOME
curl -LO https://github.com/sigp/lighthouse/releases/download/v3.2.1/lighthouse-v3.2.1-x86_64-unknown-linux-gnu.tar.gz
tar xvf lighthouse-v3.2.1-x86_64-unknown-linux-gnu.tar.gz
sudo mv lighthouse /usr/local/bin
rm lighthouse-v3.2.1-x86_64-unknown-linux-gnu.tar.gz

sudo useradd --no-create-home --shell /bin/false lighthousebeacon
sudo mkdir -p /var/lib/lighthouse/beacon
sudo chown -R lighthousebeacon:lighthousebeacon /var/lib/lighthouse/beacon

sudo tee /etc/systemd/system/lighthousebeacon.service > /dev/null <<EOF
[Unit]
Description=Lighthouse Consensus Client BN (Mainnet)
Wants=network-online.target
After=network-online.target
[Service]
User=lighthousebeacon
Group=lighthousebeacon
Type=simple
Restart=always
RestartSec=5
ExecStart=/usr/local/bin/lighthouse bn \
  --network mainnet \
  --datadir /var/lib/lighthouse \
  --http \
  --execution-endpoint http://localhost:8551 \
  --execution-jwt /var/lib/jwtsecret/jwt.hex \
  --metrics
[Install]
WantedBy=multi-user.target
EOF

printCyan "Starting Erigon & Lighthouse Beacon..." && sleep 1

sudo systemctl daemon-reload
sudo systemctl start erigon
sudo systemctl start lighthousebeacon
sudo systemctl enable erigon
sudo systemctl enable lighthousebeacon

printLine

printCyan "Check Erigon status..." && sleep 1
if [[ `service erigon status | grep active` =~ "running" ]]; then
  echo -e "Your erigon \e[32m. installed and works\e[39m!"
  echo -e "You can check node status by the command \e[7m. sudo systemctl status erigon\e[0m"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
  echo -e "You can check logs by the command \e[7m. sudo journalctl -fu erigon\e[0m"
else
  echo -e "Your erigon \e[31m. was not installed correctly\e[39m, please reinstall."
fi

printCyan "Check lighthousebeacon status..." && sleep 1
if [[ `service lighthousebeacon status | grep active` =~ "running" ]]; then
  echo -e "Your lighthousebeacon \e[32m. installed and works\e[39m!"
  echo -e "You can check node status by the command \e[7m. sudo systemctl status lighthousebeacon\e[0m"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
  echo -e "You can check logs by the command \e[7m. sudo journalctl -fu lighthousebeacon\e[0m"
else
  echo -e "Your lighthousebeacon \e[31m. was not installed correctly\e[39m, please reinstall."
fi
