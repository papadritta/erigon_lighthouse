# Erigon rollback to stable v2.27.0
# Quick update script for users who used .sh script from [kw1knode](https://github.com/kw1knode/erigon_bash_v2)

## Installation
```
git clone https://github.com/papadritta/erigon_v2.27.0.git
cd erigon_v2.27.0
chmod +x erigon.sh
./erigon.sh
```
## Check the erigon status:
```
sudo systemctl status erigon
```

## Check the erigon& logs:
```
sudo journalctl -fu erigon
```
