# Erigon rollback to stable v2.27.0
# Quick update script for users who used .sh script from [kw1knode](https://github.com/kw1knode/erigon_bash_v2)

## Run script for quick roolback
```
wget -O erigon.sh https://raw.githubusercontent.com/papadritta/erigon_v2.27.0/main/erigon.sh && chmod +x erigon.sh && ./erigon.sh
```

## Check status & logs
```
sudo systemctl status erigon
sudo journalctl -fu erigon
```
ALL DONE!
