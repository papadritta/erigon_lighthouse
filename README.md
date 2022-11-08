# Update NEW realease Erigon [v2.29.0](https://github.com/ledgerwatch/erigon/releases/tag/v2.29.0) + lighthouse [v3.2.1](https://github.com/sigp/lighthouse/tree/v3.2.1)

- officail Github page Erigon [here](https://github.com/ledgerwatch/erigon)
- officail Github page lighthouse [here](https://github.com/sigp/lighthouse)

## Automatic script for users who used manual from [kw1knode](https://github.com/kw1knode/erigon_bash_v2)

## Run script for quick update to Erigon v2.29.0 + lighthouse v3.2.1
```
wget -O erigon.v2.29.0.sh https://raw.githubusercontent.com/papadritta/erigon_v2.29.0/main/erigon.v2.29.0.sh && chmod +x erigon.v2.29.0.sh && ./erigon.v2.29.0.sh
```
## Check status & logs
```
sudo systemctl status erigon
sudo journalctl -fu erigon
```
ALL DONE!
