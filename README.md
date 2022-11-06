# Erigon update 
# Quick update script for users who used .sh script from [kw1knode](https://github.com/kw1knode/erigon_bash_v2)

## Run script for quick update to v2.29.0 [Realease here](https://github.com/ledgerwatch/erigon/releases/tag/v2.29.0)


## Run script for quick roolback to v2.27.0
```
wget -O erigon.sh https://raw.githubusercontent.com/papadritta/erigon_v2.27.0/main/erigon.sh && chmod +x erigon.sh && ./erigon.sh
```

## Check status & logs
```
sudo systemctl status erigon
sudo journalctl -fu erigon
```
ALL DONE!
