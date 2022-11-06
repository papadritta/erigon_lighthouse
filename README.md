# Update NEW realease Erigon [v2.29.0](https://github.com/ledgerwatch/erigon/releases/tag/v2.29.0)  
>officail Github page ledgerwatch+Erigon [here](https://github.com/ledgerwatch/erigon)
# Quick update script for users who used .sh script from [kw1knode](https://github.com/kw1knode/erigon_bash_v2)

## Run script for quick update to v2.29.0
```
wget -O erigon.v2.29.0.sh https://raw.githubusercontent.com/papadritta/erigon_v2.29.0/main/erigon.v2.29.0.sh && chmod +x erigon.v2.29.0.sh && ./erigon.v2.29.0.sh
```
## Run script for quick roolback to v2.27.0 (Old and stable version of Erigon)
```
wget -O erigon.sh https://raw.githubusercontent.com/papadritta/erigon_v2.27.0/main/erigon.sh && chmod +x erigon.sh && ./erigon.sh
```

## Check status & logs
```
sudo systemctl status erigon
sudo journalctl -fu erigon
```
ALL DONE!
