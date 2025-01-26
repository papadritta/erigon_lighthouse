#!/bin/bash

exists() {
  command -v "$1" >/dev/null 2>&1
}

check_installed() {
  systemctl is-active --quiet "$1" && echo "true" || echo "false"
}

printLogo() {
  echo -e "\e[34m"  # Blue color
  echo "============================================================="
  echo "   ███████╗ ██████╗  ██╗  ██████╗   ██████╗  ███╗   ██╗"
  echo "   ██╔════╝ ██╔══██╗ ██║ ██╔════╝  ██╔═══██╗ ████╗  ██║"
  echo "   █████╗   ██████╔╝ ██║ ██║  ███╗ ██║   ██║ ██╔██╗ ██║"
  echo "   ██╔══╝   ██╔═══╝  ██║ ██║   ██║ ██║   ██║ ██║╚██╗██║"
  echo "   ███████╗ ██║ ╚██╗ ██║ ╚██████╔╝ ╚██████╔╝ ██║ ╚████║"
  echo "   ╚══════╝ ╚═╝  ╚═╝ ╚═╝  ╚═════╝   ╚═════╝  ╚═╝  ╚═══╝"
  echo "============================================================="
  echo -e "\e[39m"  # Reset color
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

# Ensure `curl` is installed
if ! exists curl; then
  sudo apt update && sudo apt install curl -y < "/dev/null"
fi

# Source the .bash_profile if it exists (ShellCheck directive added)
# shellcheck source=/dev/null
if [ -f "$HOME/.bash_profile" ]; then
  . "$HOME/.bash_profile"
fi

printLogo

printCyan "Updating packages..." && sleep 1
sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y

printCyan "Installing dependencies..." && sleep 1
sudo apt-get update
sudo apt-get install -y git clang llvm ca-certificates curl build-essential \
  binaryen protobuf-compiler libssl-dev pkg-config libclang-dev cmake jq gcc g++ \
  libssl-dev protobuf-compiler clang llvm

printCyan "Installing Golang..." && sleep 1
cd "$HOME" || exit
curl -LO https://go.dev/dl/go1.19.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.19.3.linux-amd64.tar.gz
export PATH="$PATH:/usr/local/go/bin"
# Explicitly source profile if available
if [ -f "$HOME/.profile" ]; then
  # shellcheck source=/dev/null
  source "$HOME/.profile"
fi
rm go1.19.3.linux-amd64.tar.gz

printCyan "Setting jwtsecret..." && sleep 1
cd "$HOME" || exit
sudo mkdir -p /var/lib/jwtsecret
openssl rand -hex 32 | sudo tee /var/lib/jwtsecret/jwt.hex > /dev/null

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
  if ! make erigon; then
    printRed "Error: Failed to build Erigon. Check the logs for details."
    exit 1
  fi

  cd "$HOME" || exit
  sudo mv erigon-2.61.0 /usr/local/bin/erigon
  rm v2.61.0.tar.gz

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

install_or_update_erigon

printLine

printCyan "Check Erigon status..." && sleep 1
if [[ $(systemctl is-active erigon) == "active" ]]; then
  echo -e "Your Erigon \e[32mhas been installed and is running correctly\e[39m!"
else
  echo -e "Your Erigon \e[31mwas not installed or started correctly\e[39m."
fi

printCyan "ALL DONE!" && sleep 1
