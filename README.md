# Installation  NEW release Erigon [v2.29.0](https://github.com/ledgerwatch/erigon/releases/tag/v2.29.0) + lighthouse [v3.2.1](https://github.com/sigp/lighthouse/tree/v3.2.1) or quick update
![Copy of Copy of Copy of Staking is live](https://user-images.githubusercontent.com/90826754/200572250-6746122b-2dc4-4825-807c-4142ce2cef12.png)

- official Github page Erigon [here](https://github.com/ledgerwatch/erigon)
- official Github page lighthouse [here](https://github.com/sigp/lighthouse)

## Node Specs

|      | Minimum       | Recommended    | Maxed out         |
| :---:|     :---:     |      :---:     |      :---:        |
| CPUs | 16 vcore      | 32 vcore       | 64 vcore          |
| RAM  | 32 G          | 64 GB          | 128 GB            |
| SSD  | 3 TB SATA SSD |5 TB NVME       | 5 TB NVME RAID 10	|
	

## Installation Erigon v2.29.0 + lighthouse v3.2.1
```
wget -O erigon.sh https://raw.githubusercontent.com/papadritta/erigon_lighthouse/main/erigon.sh && chmod +x erigon.sh && ./erigon.sh
```
## or
## Update to Erigon v2.29.0 + lighthouse v3.2.1
>works only if you use installation script above with different version of Erigon & Lighthouse
```
wget -O erigon.v2.29.0.sh https://raw.githubusercontent.com/papadritta/erigon_v2.29.0/main/erigon.v2.29.0.sh && chmod +x erigon.v2.29.0.sh && ./erigon.v2.29.0.sh
```
## Check status & logs
- Erigon
```
sudo systemctl status erigon
sudo journalctl -fu erigon
```
- Lighthouse
```
sudo systemctl status lighthousebeacon
sudo journalctl -fu lighthousebeacon
```
## Delete Erigon + lighthouse
```
wget -O delete.sh https://raw.githubusercontent.com/papadritta/erigon_lighthouse/main/delete.sh && chmod +x delete.sh && ./delete.sh
```
## You need a server?
- Use the links with referal programm <a href="https://www.vultr.com/?ref=8997131"><img width="200" src="https://user-images.githubusercontent.com/90826754/200262610-b6251a9b-36a9-44f7-be30-fa691e7238de.png" a>
            <a href="https://www.digitalocean.com/?refcode=87b8b298c106&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge"><img src="https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%201.svg" alt="DigitalOcean Referral Badge" /></a>

**NOTE!: use a referal link & you will get 100$ to your server provider account**

ALL DONE!
