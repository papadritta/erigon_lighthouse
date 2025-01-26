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

printCyan() { echo -e "\e[96m$1\e[39m"; }

printRed() { echo -e "\e[91m$1\e[39m"; }

printLine() { echo "============================================================="; }

loadProfile() {
  if [ -f "$HOME/.bash_profile" ]; then
    . "$HOME/.bash_profile"
  else
    echo "Warning: $HOME/.bash_profile not found. Skipping."
  fi

  if [ -f "$HOME/.profile" ]; then
    source "$HOME/.profile"
  else
    echo "Warning: $HOME/.profile not found. Skipping."
  fi
}

printLogo
loadProfile

printCyan "Updating packages..." && sleep 1
sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y

printCyan "Installing dependencies..." && sleep 1
sudo apt-get update
sudo apt-get install -y git clang llvm ca-certificates curl build-essential binaryen \
  protobuf-compiler libssl-dev pkg-config libclang-dev cmake jq gcc g++ libssl-dev

printCyan "Installing Golang..." && sleep 1
cd "$HOME" || exit
curl -LO https://go.dev/dl/go1.19.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.19.3.linux-amd64.tar.gz
export PATH="$PATH:/usr/local/go/bin"
source "$HOME/.profile"
rm go1.19.3.linux-amd64.tar.gz

printCyan "Setting JWT secret..." && sleep 1
sudo mkdir -p /var/lib/jwtsecret
openssl rand -hex 32 | sudo tee /var/lib/jwtsecret/jwt.hex > /dev/null

ERIGON_VERSION=$(curl -s https://api.github.com/repos/erigontech/erigon/releases/latest | jq -r .tag_name)
LIGHTHOUSE_VERSION=$(curl -s https://api.github.com/repos/sigp/lighthouse/releases/latest | jq -r .tag_name)

install_erigon() {
  local version="$1"
  printCyan "Installing or updating Erigon to version $version..."

  if [ "$(check_installed erigon)" == "true" ]; then
    printCyan "Erigon is already installed. Updating to version $version..." && sleep 1
    sudo systemctl stop erigon
    sudo rm -rf /usr/local/bin/erigon
  else
    printCyan "Installing Erigon version $version for the first time..." && sleep 1
  fi

  cd "$HOME" || exit
  curl -LO "https://github.com/erigontech/erigon/archive/refs/tags/${version}.tar.gz"
  tar xvf "${version}.tar.gz"
  cd "erigon-${version#v}" || exit

  printCyan "Building Erigon..." && sleep 1
  make erigon
  if [[ $? -ne 0 ]]; then
    printRed "Error: Failed to build Erigon. Check the logs for details."
    exit 1
  fi

  cd "$HOME" || exit
  sudo mv "erigon-${version#v}" /usr/local/bin/erigon
  rm "${version}.tar.gz"

  sudo useradd --no-create-home --shell /bin/false erigon || true
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

  sudo systemctl daemon-reload
  sudo systemctl enable erigon
  sudo systemctl start erigon
  printCyan "Erigon installation or update completed successfully!"
}

install_lighthouse() {
  local version="$1"
  printCyan "Installing or updating Lighthouse to version $version..."

  if [ "$(check_installed lighthousebeacon)" == "true" ]; then
    printCyan "Lighthouse is already installed. Updating to version $version..." && sleep 1
    sudo systemctl stop lighthousebeacon
    sudo rm -rf /usr/local/bin/lighthouse
  else
    printCyan "Installing Lighthouse version $version for the first time..." && sleep 1
  fi

  cd "$HOME" || exit
  curl -LO "https://github.com/sigp/lighthouse/releases/download/${version}/lighthouse-${version}-x86_64-unknown-linux-gnu.tar.gz"
  tar xvf "lighthouse-${version}-x86_64-unknown-linux-gnu.tar.gz"
  sudo mv lighthouse /usr/local/bin
  rm "lighthouse-${version}-x86_64-unknown-linux-gnu.tar.gz"

  sudo useradd --no-create-home --shell /bin/false lighthousebeacon || true
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

  sudo systemctl daemon-reload
  sudo systemctl enable lighthousebeacon
  sudo systemctl start lighthousebeacon
  printCyan "Lighthouse installation or update completed successfully!"
}

install_erigon "$ERIGON_VERSION"
install_lighthouse "$LIGHTHOUSE_VERSION"

printLine

printCyan "Check Erigon status..." && sleep 1
if [[ $(systemctl is-active erigon) == "active" ]]; then
  echo -e "Your Erigon \e[32mis installed and running correctly\e[39m!"
else
  echo -e "Your Erigon \e[31mwas not installed correctly\e[39m. Please check logs."
fi

printCyan "Check Lighthouse Beacon status..." && sleep 1
if [[ $(systemctl is-active lighthousebeacon) == "active" ]]; then
  echo -e "Your Lighthouse Beacon \e[32mis installed and running correctly\e[39m!"
else
  echo -e "Your Lighthouse Beacon \e[31mwas not installed correctly\e[39m. Please check logs."
fi

printCyan "ALL DONE!"
