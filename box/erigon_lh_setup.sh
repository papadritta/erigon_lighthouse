#!/bin/bash

exists() {
  command -v "$1" >/dev/null 2>&1
}

check_installed() {
  systemctl is-active --quiet "$1" && echo "true" || echo "false"
}

printLogo() {
  echo -e "\e[34m"
  echo "============================================================="
  echo "   ███████╗ ██████╗  ██╗  ██████╗   ██████╗  ███╗   ██╗"
  echo "   ██╔════╝ ██╔══██╗ ██║ ██╔════╝  ██╔═══██╗ ████╗  ██║"
  echo "   █████╗   ██████╔╝ ██║ ██║  ███╗ ██║   ██║ ██╔██╗ ██║"
  echo "   ██╔══╝   ██╔═══╝  ██║ ██║   ██║ ██║   ██║ ██║╚██╗██║"
  echo "   ███████╗ ██║ ╚██╗ ██║ ╚██████╔╝ ╚██████╔╝ ██║ ╚████║"
  echo "   ╚══════╝ ╚═╝  ╚═╝ ╚═╝  ╚═════╝   ╚═════╝  ╚═╝  ╚═══╝"
  echo "============================================================="
  echo -e "\e[39m"
}

printCyan() {
  echo -e "\e[96m$1\e[39m"
}

printRed() {
  echo -e "\e[91m$1\e[39m"
}

printLine() {
  echo "============================================================="
}

if ! exists curl; then
  sudo apt update && sudo apt install curl -y < "/dev/null"
fi

if [ -f "$HOME/.bash_profile" ]; then
  . "$HOME/.bash_profile"
fi

if [ -f "$HOME/.profile" ]; then
  source "$HOME/.profile"
fi

printLogo

printCyan "Updating packages..." && sleep 1
sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y

printCyan "Installing dependencies..." && sleep 1
sudo apt-get update
sudo apt-get install -y git clang llvm ca-certificates curl build-essential \
  binaryen protobuf-compiler libssl-dev pkg-config libclang-dev cmake jq \
  gcc g++ libssl-dev protobuf-compiler clang llvm

printCyan "Installing Golang..." && sleep 1
cd "$HOME" || exit
curl -LO https://go.dev/dl/go1.19.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.19.3.linux-amd64.tar.gz
export PATH="$PATH:/usr/local/go/bin"
if [ -f "$HOME/.profile" ]; then
  source "$HOME/.profile"
fi
rm go1.19.3.linux-amd64.tar.gz

printCyan "Setting jwtsecret..." && sleep 1
sudo mkdir -p /var/lib/jwtsecret
openssl rand -hex 32 | sudo tee /var/lib/jwtsecret/jwt.hex >/dev/null

install_or_update_erigon() {
  if [ "$(check_installed erigon)" == "true" ]; then
    printCyan "Updating Erigon..." && sleep 1
    sudo systemctl stop erigon
    sudo rm -rf /usr/local/bin/erigon
  else
    printCyan "Installing Erigon..." && sleep 1
  fi

  cd "$HOME" || exit
  curl -LO https://github.com/erigontech/erigon/archive/refs/tags/v2.61.0.tar.gz
  tar xvf v2.61.0.tar.gz
  cd "erigon-2.61.0" || exit

  printCyan "Building Erigon..." && sleep 1
  make erigon
  if ! [ $? -eq 0 ]; then
    printRed "Error: Failed to build Erigon. Check the logs for details."
    exit 1
  fi

  cd "$HOME" || exit
  sudo mv erigon-2.61.0 /usr/local/bin/erigon
  rm v2.61.0.tar.gz

  sudo useradd --no-create-home --shell /bin/false erigon || true
  sudo mkdir -p /var/lib/erigon
  sudo chown -R erigon:erigon /var/lib/erigon

  sudo tee /etc/systemd/system/erigon.service >/dev/null <<EOF
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
ExecStart=/usr/local/bin/erigon/build/erigon \
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

  sudo systemctl daemon-reload
  sudo systemctl enable erigon
  sudo systemctl start erigon
}

install_or_update_lighthouse() {
  if [ "$(check_installed lighthousebeacon)" == "true" ]; then
    printCyan "Updating Lighthouse..." && sleep 1
    sudo systemctl stop lighthousebeacon
    sudo rm -rf /usr/local/bin/lighthouse
  else
    printCyan "Installing Lighthouse Beacon..." && sleep 1
  fi

  cd "$HOME" || exit
  curl -LO https://github.com/sigp/lighthouse/releases/download/v6.0.1/lighthouse-v6.0.1-x86_64-unknown-linux-gnu.tar.gz
  tar xvf lighthouse-v6.0.1-x86_64-unknown-linux-gnu.tar.gz
  sudo mv lighthouse /usr/local/bin
  rm lighthouse-v6.0.1-x86_64-unknown-linux-gnu.tar.gz

  sudo useradd --no-create-home --shell /bin/false lighthousebeacon || true
  sudo mkdir -p /var/lib/lighthouse/beacon
  sudo chown -R lighthousebeacon:lighthousebeacon /var/lib/lighthouse/beacon

  sudo tee /etc/systemd/system/lighthousebeacon.service >/dev/null <<EOF
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

  sudo systemctl daemon-reload
  sudo systemctl enable lighthousebeacon
  sudo systemctl start lighthousebeacon
}

install_or_update_erigon
install_or_update_lighthouse

printLine

printCyan "Check Erigon status..." && sleep 1
if [[ $(systemctl is-active erigon) == "active" ]]; then
  echo -e "Your Erigon \e[32mhas been installed and is running correctly\e[39m!"
  echo -e "Check node status: \e[7msudo systemctl status erigon\e[0m"
  echo -e "View logs: \e[7msudo journalctl -fu erigon\e[0m"
else
  echo -e "Your Erigon \e[31mwas not installed or started correctly\e[39m."
  echo -e "Check logs: \e[7msudo journalctl -xeu erigon\e[0m"
fi

printCyan "Check Lighthouse Beacon status..." && sleep 1
if [[ $(systemctl is-active lighthousebeacon) == "active" ]]; then
  echo -e "Your Lighthouse Beacon \e[32mhas been installed and is running correctly\e[39m!"
  echo -e "Check node status: \e[7msudo systemctl status lighthousebeacon\e[0m"
  echo -e "View logs: \e[7msudo journalctl -fu lighthousebeacon\e[0m"
else
  echo -e "Your Lighthouse Beacon \e[31mwas not installed or started correctly\e[39m."
  echo -e "Check logs: \e[7msudo journalctl -xeu lighthousebeacon\e[0m"
fi

printCyan "ALL DONE!" && sleep 1
