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

# shellcheck disable=SC1091
if [ -f "$HOME/.bash_profile" ]; then
  . "$HOME/.bash_profile"
else
  echo "Warning: $HOME/.bash_profile not found. Skipping."
fi
# shellcheck disable=SC1091
if [ -f "$HOME/.profile" ]; then
  source "$HOME/.profile"
else
  echo "Warning: $HOME/.profile not found. Skipping."
fi

printLogo

printCyan "Updating packages..." && sleep 1
sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y

printCyan "Installing dependencies..." && sleep 1
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
  if ! make erigon; then
    printRed "Error: Failed to build Erigon. Check the logs for details."
    exit 1
  fi

  cd "$HOME" || exit
  sudo mv erigon-2.61.0 /usr/local/bin/erigon
  rm v2.61.0.tar.gz

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
  echo -e "You can check the node status with the command: \e[7msudo systemctl status erigon\e[0m"
  echo -e "Press \e[7mQ\e[0m to exit the status menu."
  echo -e "You can also view logs with: \e[7msudo journalctl -fu erigon\e[0m"
else
  echo -e "Your Erigon \e[31mwas not installed or started correctly\e[39m."
  echo -e "Please check the logs with: \e[7msudo journalctl -xeu erigon\e[0m and restart the script."
fi

printCyan "Check Lighthouse Beacon status..." && sleep 1
if [[ $(systemctl is-active lighthousebeacon) == "active" ]]; then
  echo -e "Your Lighthouse Beacon \e[32mhas been installed and is running correctly\e[39m!"
  echo -e "You can check the node status with the command: \e[7msudo systemctl status lighthousebeacon\e[0m"
  echo -e "Press \e[7mQ\e[0m to exit the status menu."
  echo -e "You can also view logs with: \e[7msudo journalctl -fu lighthousebeacon\e[0m"
else
  echo -e "Your Lighthouse Beacon \e[31mwas not installed or started correctly\e[39m."
  echo -e "Please check the logs with: \e[7msudo journalctl -xeu lighthousebeacon\e[0m and restart the script."
fi

printCyan "ALL DONE!" && sleep 1
